#!/usr/bin/env python3
"""Exporta o histórico do projeto para `metrics/raw/` (somente leitura).

Fontes:
  - SQLite local do OpenCode (sessões, mensagens, tool calls, tokens)
  - git log --numstat
  - GitHub issues (opcional, via gh)
  - logs de CI em /tmp/opencode/ci_*.log (opcional)

O raw é privado e fica fora do git (`metrics/.gitignore`). Use
`tools/metrics.py` para gerar os agregados versionados.

Uso:
  python3 tools/export_history.py --with-github --with-comments
  python3 tools/export_history.py --db ~/.local/share/opencode/opencode.db
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_DB = Path.home() / ".local" / "share" / "opencode" / "opencode.db"
DEFAULT_RAW = ROOT / "metrics" / "raw"

SECRET_RE = re.compile(
    r"(gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}"
    r"|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}"
    r"|AKIA[0-9A-Z]{16})"
)


def iso_ms(value: int | None) -> str:
    if not value:
        return ""
    return datetime.fromtimestamp(value / 1000.0, tz=timezone.utc).isoformat()


def redact(text: str) -> str:
    if not text:
        return ""
    text = text.replace(str(ROOT), "<project>")
    text = text.replace(str(Path.home()), "~")
    return SECRET_RE.sub("[REDACTED]", text)


def cap(text: str, limit: int) -> tuple[str, int]:
    size = len(text)
    if size <= limit:
        return text, size
    return text[:limit] + f"\n...[truncated {size - limit} chars]", size


def write_jsonl(path: Path, rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")


def connect(db: Path) -> sqlite3.Connection:
    return sqlite3.connect(f"file:{db}?mode=ro", uri=True)


def export_sessions(con: sqlite3.Connection, project: Path) -> list[dict]:
    rows = con.execute(
        """select id,title,directory,parent_id,agent,model,time_created,
                  time_updated,time_busy,time_idle,cost,tokens_input,
                  tokens_output,tokens_reasoning,tokens_cache_read,
                  tokens_cache_write
           from session_v2 where directory = ? order by time_created""",
        (str(project),),
    ).fetchall()
    out = []
    for row in rows:
        out.append({
            "id": row[0], "title": redact(row[1] or ""), "directory": row[2],
            "parent_id": row[3], "agent": row[4], "model": row[5],
            "created": iso_ms(row[6]), "updated": iso_ms(row[7]),
            "busy": iso_ms(row[8]), "idle": iso_ms(row[9]),
            "cost": row[10] or 0,
            "tokens": {
                "input": row[11] or 0, "output": row[12] or 0,
                "reasoning": row[13] or 0, "cache_read": row[14] or 0,
                "cache_write": row[15] or 0,
            },
        })
    return out


def normalize_tokens(raw: dict) -> dict:
    raw = raw or {}
    cache = raw.get("cache", {}) if isinstance(raw.get("cache"), dict) else {}
    return {
        "input": int(raw.get("input", 0) or 0),
        "output": int(raw.get("output", 0) or 0),
        "reasoning": int(raw.get("reasoning", 0) or 0),
        "cache_read": int(cache.get("read", 0) or 0),
        "cache_write": int(cache.get("write", 0) or 0),
    }


def message_text(data: dict) -> tuple[str, str]:
    text_parts: list[str] = []
    reasoning_parts: list[str] = []
    for part in data.get("content", []) or []:
        if not isinstance(part, dict):
            continue
        if part.get("type") == "text":
            text_parts.append(part.get("text", ""))
        elif part.get("type") == "reasoning":
            reasoning_parts.append(part.get("text", ""))
    if data.get("text"):
        text_parts.insert(0, str(data["text"]))
    return "\n".join(filter(None, text_parts)), "\n".join(filter(None, reasoning_parts))


def export_messages(con: sqlite3.Connection, session_ids: list[str],
                    max_output: int) -> tuple[list[dict], list[dict]]:
    if not session_ids:
        return [], []
    marks = ",".join("?" * len(session_ids))
    rows = con.execute(
        f"""select id,session_id,type,seq,time_created,time_updated,data
            from session_message where session_id in ({marks})
            order by time_created, seq""",
        session_ids,
    ).fetchall()
    messages: list[dict] = []
    tools: list[dict] = []
    for row in rows:
        msg_id, session_id, kind, seq, created, updated, raw = row
        try:
            data = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            data = {}
        text, reasoning = message_text(data)
        text, text_chars = cap(redact(text), max_output)
        reasoning, reasoning_chars = cap(redact(reasoning), max_output)
        model = data.get("model") or {}
        message = {
            "id": msg_id, "session_id": session_id, "type": kind, "seq": seq,
            "created": iso_ms(created), "updated": iso_ms(updated),
            "agent": data.get("agent", ""),
            "model": model.get("id", "") if isinstance(model, dict) else "",
            "text": text, "text_chars": text_chars,
            "reasoning": reasoning, "reasoning_chars": reasoning_chars,
            "finish": data.get("finish", ""),
            "tokens": normalize_tokens(data.get("tokens", {})),
            "cost": data.get("cost", 0),
        }
        messages.append(message)
        for part in data.get("content", []) or []:
            if not isinstance(part, dict) or part.get("type") != "tool":
                continue
            state = part.get("state", {}) or {}
            content = state.get("content", []) or []
            chunks: list[str] = []
            for item in content:
                if isinstance(item, dict) and item.get("type") == "text":
                    chunks.append(item.get("text", ""))
                elif isinstance(item, str):
                    chunks.append(item)
            output = "\n".join(chunks)
            output, output_chars = cap(redact(output), max_output)
            payload = state.get("input", {})
            input_text = json.dumps(payload, ensure_ascii=False) if not isinstance(payload, str) else payload
            input_text, input_chars = cap(redact(input_text), max_output)
            timing = part.get("time", {}) or {}
            ran = timing.get("ran")
            completed = timing.get("completed")
            tools.append({
                "id": part.get("id", ""),
                "session_id": session_id,
                "message_id": msg_id,
                "name": part.get("name", ""),
                "status": state.get("status", ""),
                "created": iso_ms(timing.get("created")),
                "ran": iso_ms(ran),
                "completed": iso_ms(completed),
                "duration_ms": (completed - ran) if ran and completed else 0,
                "input": input_text,
                "input_chars": input_chars,
                "output": output,
                "output_chars": output_chars,
            })
    return messages, tools


def export_commits() -> list[dict]:
    marker = "@@@COMMIT@@@"
    try:
        out = subprocess.run(
            ["git", "log", "--numstat", "--pretty=format:" + marker
             + "%H%x1f%an%x1f%aI%x1f%s%x1f%b"],
            cwd=ROOT, check=True, capture_output=True, text=True,
        ).stdout
    except subprocess.CalledProcessError:
        return []
    commits: list[dict] = []
    current: dict | None = None
    for line in out.splitlines():
        if line.startswith(marker):
            fields = line[len(marker):].split("\x1f")
            if len(fields) < 5:
                current = None
                continue
            body = fields[4]
            current = {
                "hash": fields[0], "author": fields[1], "date": fields[2],
                "subject": fields[3], "body": body,
                "files": [], "additions": 0, "deletions": 0,
                "issues": sorted({
                    int(n) for n in re.findall(
                        r"(?:#|issues/)(\d+)", fields[3] + "\n" + body
                    )
                }),
            }
            commits.append(current)
            continue
        if current is None:
            continue
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        add, delete, path = parts
        current["files"].append(path)
        current["additions"] += int(add) if add.isdigit() else 0
        current["deletions"] += int(delete) if delete.isdigit() else 0
    return commits


def export_issues(with_comments: bool) -> list[dict] | None:
    try:
        out = subprocess.run(
            ["gh", "issue", "list", "--state", "all", "--limit", "200",
             "--json", "number,title,state,createdAt,closedAt,labels,milestone,author,url,body"],
            cwd=ROOT, check=True, capture_output=True, text=True,
        ).stdout
        raw = json.loads(out)
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"WARN GitHub indisponível: {exc}", file=sys.stderr)
        return None
    issues = []
    for issue in raw:
        labels = [label.get("name", "") for label in issue.get("labels", [])]
        milestone = issue.get("milestone") or {}
        comments = []
        if with_comments:
            try:
                detail = subprocess.run(
                    ["gh", "issue", "view", str(issue["number"]),
                     "--json", "comments"],
                    cwd=ROOT, check=True, capture_output=True, text=True,
                ).stdout
                for comment in json.loads(detail).get("comments", []):
                    comments.append({
                        "author": (comment.get("author") or {}).get("login", ""),
                        "created": comment.get("createdAt", ""),
                        "body": cap(redact(comment.get("body", "")), 20000)[0],
                    })
            except subprocess.CalledProcessError:
                pass
        issues.append({
            "number": issue["number"], "title": issue["title"],
            "state": issue["state"], "created": issue.get("createdAt", ""),
            "closed": issue.get("closedAt", ""),
            "labels": labels, "milestone": milestone.get("title", ""),
            "author": (issue.get("author") or {}).get("login", ""),
            "url": issue.get("url", ""),
            "body": cap(redact(issue.get("body", "")), 20000)[0],
            "comments": comments,
        })
    return issues


def export_ci(raw: Path, extra_logs: list[str]) -> list[dict]:
    ci_dir = raw / "ci"
    ci_dir.mkdir(parents=True, exist_ok=True)
    candidates = [Path(p) for p in extra_logs]
    candidates += sorted(Path("/tmp/opencode").glob("ci_*.log"))
    rows = []
    for path in candidates:
        if not path.is_file():
            continue
        target = ci_dir / path.name
        shutil.copy2(path, target)
        text = path.read_text(encoding="utf-8", errors="replace")
        gates = re.findall(r"\b([A-Z][A-Z0-9_]*_(?:OK|FAIL))\b", text)
        failures = sorted({gate for gate in gates if gate.endswith("_FAIL")})
        rows.append({
            "log": target.name,
            "mtime": datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc).isoformat(),
            "gates": sorted(set(gates)),
            "failures": failures,
        })
    return rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", type=Path, default=DEFAULT_DB)
    parser.add_argument("--raw", type=Path, default=DEFAULT_RAW)
    parser.add_argument("--project", type=Path, default=ROOT)
    parser.add_argument("--with-github", action="store_true")
    parser.add_argument("--with-comments", action="store_true")
    parser.add_argument("--ci-log", action="append", default=[])
    parser.add_argument("--max-output-chars", type=int, default=20000)
    args = parser.parse_args()

    if not args.db.exists():
        print(f"FAIL DB não encontrada: {args.db}", file=sys.stderr)
        return 1
    args.raw.mkdir(parents=True, exist_ok=True)

    con = connect(args.db)
    sessions = export_sessions(con, args.project)
    ids = [session["id"] for session in sessions]
    messages, tools = export_messages(con, ids, args.max_output_chars)
    con.close()

    write_jsonl(args.raw / "sessions.jsonl", sessions)
    write_jsonl(args.raw / "messages.jsonl", messages)
    write_jsonl(args.raw / "tool_calls.jsonl", tools)
    commits = export_commits()
    write_jsonl(args.raw / "commits.jsonl", commits)
    ci = export_ci(args.raw, args.ci_log)
    write_jsonl(args.raw / "ci.jsonl", ci)

    issues = export_issues(args.with_comments) if args.with_github else None
    if issues is not None:
        (args.raw / "issues.json").write_text(
            json.dumps(issues, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "project": str(args.project),
        "db": str(args.db),
        "sessions": len(sessions),
        "messages": len(messages),
        "tool_calls": len(tools),
        "commits": len(commits),
        "ci_logs": len(ci),
        "issues": len(issues) if issues is not None else None,
        "with_comments": args.with_comments,
        "max_output_chars": args.max_output_chars,
    }
    (args.raw / "manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print("RAW_OK", json.dumps(manifest, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())

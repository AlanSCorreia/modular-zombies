#!/usr/bin/env python3
"""Agrega `metrics/raw/` em CSV/JSON versionáveis.

Uso:
  python3 tools/metrics.py
"""

from __future__ import annotations

import csv
import json
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "metrics" / "raw"
OUT = ROOT / "metrics" / "aggregates"


def load_jsonl(name: str) -> list[dict]:
    path = RAW / name
    if not path.exists():
        return []
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def load_json(name: str, fallback):
    path = RAW / name
    if not path.exists():
        return fallback
    return json.loads(path.read_text(encoding="utf-8"))


def write_csv(path: Path, headers: list[str], rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=headers)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: row.get(key, "") for key in headers})


def work_log_links() -> dict[int, set[str]]:
    mapping: dict[int, set[str]] = defaultdict(set)
    current: int | None = None
    for rel in ("docs/planning/20-work-log.md",
                "docs/planning/archive/20-work-log-2026-11-detalhado.md"):
        path = ROOT / rel
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            heading = re.search(r"(?:issue #|issues/)(\d+)", line)
            if line.startswith(("## ", "**")) and heading:
                current = int(heading.group(1))
            if current is None:
                continue
            for commit_hash in re.findall(r"`([0-9a-f]{7,40})`", line):
                mapping[current].add(commit_hash)
    return mapping


def day_of(iso: str) -> str:
    return iso[:10] if iso else ""


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    sessions = load_jsonl("sessions.jsonl")
    messages = load_jsonl("messages.jsonl")
    tools = load_jsonl("tool_calls.jsonl")
    commits = load_jsonl("commits.jsonl")
    ci = load_jsonl("ci.jsonl")
    issues = load_json("issues.json", [])

    msgs_by_session: dict[str, list[dict]] = defaultdict(list)
    tools_by_session: dict[str, list[dict]] = defaultdict(list)
    for message in messages:
        msgs_by_session[message.get("session_id", "")].append(message)
    for tool in tools:
        tools_by_session[tool.get("session_id", "")].append(tool)

    token_totals = {"input": 0, "output": 0, "reasoning": 0,
                    "cache_read": 0, "cache_write": 0}
    per_session = []
    for session in sessions:
        sid = session["id"]
        sess_msgs = msgs_by_session.get(sid, [])
        sess_tools = tools_by_session.get(sid, [])
        tokens = {"input": 0, "output": 0, "reasoning": 0,
                  "cache_read": 0, "cache_write": 0}
        for message in sess_msgs:
            message_tokens = message.get("tokens") or {}
            for key in tokens:
                tokens[key] += int(message_tokens.get(key, 0) or 0)
        for key in token_totals:
            token_totals[key] += tokens[key]
        start = session.get("created", "")
        end = session.get("updated", "")
        duration = 0.0
        if start and end:
            duration = (datetime.fromisoformat(end) - datetime.fromisoformat(start)).total_seconds() / 3600.0
        per_session.append({
            "session": sid,
            "title": session.get("title", ""),
            "parent": session.get("parent_id") or "",
            "start": start,
            "end": end,
            "duration_h": round(duration, 2),
            "messages": len(sess_msgs),
            "tool_calls": len(sess_tools),
            "tokens_input": tokens["input"],
            "tokens_output": tokens["output"],
            "tokens_reasoning": tokens["reasoning"],
            "cache_read": tokens["cache_read"],
            "cost": session.get("cost", 0),
        })

    tool_counts = Counter(tool.get("name", "") for tool in tools)
    tool_status = Counter(tool.get("status", "") for tool in tools)

    per_day: dict[str, dict] = defaultdict(lambda: {
        "date": "", "sessions": set(), "messages": 0, "tool_calls": 0,
        "tokens_input": 0, "tokens_output": 0, "commits": 0,
        "additions": 0, "deletions": 0,
    })
    for message in messages:
        day = day_of(message.get("created", ""))
        if not day:
            continue
        per_day[day]["date"] = day
        per_day[day]["sessions"].add(message.get("session_id", ""))
        per_day[day]["messages"] += 1
        tokens = message.get("tokens") or {}
        per_day[day]["tokens_input"] += int(tokens.get("input", 0) or 0)
        per_day[day]["tokens_output"] += int(tokens.get("output", 0) or 0)
    for tool in tools:
        day = day_of(tool.get("created", ""))
        if day:
            per_day[day]["date"] = day
            per_day[day]["tool_calls"] += 1
    for commit in commits:
        day = commit.get("date", "")[:10]
        if not day:
            continue
        per_day[day]["date"] = day
        per_day[day]["commits"] += 1
        per_day[day]["additions"] += int(commit.get("additions", 0) or 0)
        per_day[day]["deletions"] += int(commit.get("deletions", 0) or 0)
    day_rows = []
    for day in sorted(per_day):
        row = per_day[day]
        day_rows.append({
            "date": day,
            "sessions": len(row["sessions"]),
            "messages": row["messages"],
            "tool_calls": row["tool_calls"],
            "tokens_input": row["tokens_input"],
            "tokens_output": row["tokens_output"],
            "commits": row["commits"],
            "additions": row["additions"],
            "deletions": row["deletions"],
        })

    docs_text = ""
    for rel in ("KANBAN.md", "docs/planning/19-decision-log.md",
                "docs/planning/20-work-log.md", "docs/planning/06-backlog.md"):
        path = ROOT / rel
        if path.exists():
            docs_text += "\n" + path.read_text(encoding="utf-8")
    issue_rows = []
    commit_links = work_log_links()
    for issue in issues:
        number = int(issue.get("number", 0))
        lead_hours = ""
        if issue.get("created") and issue.get("closed"):
            created = datetime.fromisoformat(issue["created"].replace("Z", "+00:00"))
            closed = datetime.fromisoformat(issue["closed"].replace("Z", "+00:00"))
            lead_hours = round((closed - created).total_seconds() / 3600.0, 2)
        hashes = commit_links.get(number, set())
        linked = [
            commit for commit in commits
            if number in commit.get("issues", [])
            or any(str(commit.get("hash", "")).startswith(h) for h in hashes)
        ]
        mentions = len(re.findall(rf"(?:#|issues/){number}\b", docs_text))
        issue_rows.append({
            "number": number,
            "title": issue.get("title", ""),
            "state": issue.get("state", ""),
            "created": issue.get("created", ""),
            "closed": issue.get("closed", ""),
            "lead_hours": lead_hours,
            "labels": " ".join(issue.get("labels", [])),
            "milestone": issue.get("milestone", ""),
            "commits_linked": len(linked),
            "commit_additions": sum(int(c.get("additions", 0) or 0) for c in linked),
            "commit_deletions": sum(int(c.get("deletions", 0) or 0) for c in linked),
            "docs_mentions": mentions,
        })

    gate_counts = Counter()
    for log in ci:
        for gate in log.get("gates", []):
            gate_counts[gate] += 1
    failures = sum(1 for log in ci for _ in log.get("failures", []))

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "sessions": len(sessions),
        "messages": len(messages),
        "tool_calls": len(tools),
        "commits": len(commits),
        "issues": {
            "total": len(issues),
            "open": sum(1 for issue in issues if issue.get("state") == "OPEN"),
            "closed": sum(1 for issue in issues if issue.get("state") == "CLOSED"),
        },
        "tokens": token_totals,
        "tools": dict(tool_counts.most_common()),
        "tool_status": dict(tool_status),
        "ci": {"logs": len(ci), "gate_counts": dict(gate_counts), "failures": failures},
    }
    (OUT / "summary.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    write_csv(OUT / "per_session.csv", [
        "session", "title", "parent", "start", "end", "duration_h",
        "messages", "tool_calls", "tokens_input", "tokens_output",
        "tokens_reasoning", "cache_read", "cost",
    ], per_session)
    write_csv(OUT / "per_day.csv", [
        "date", "sessions", "messages", "tool_calls", "tokens_input",
        "tokens_output", "commits", "additions", "deletions",
    ], day_rows)
    write_csv(OUT / "per_issue.csv", [
        "number", "title", "state", "created", "closed", "lead_hours",
        "labels", "milestone", "commits_linked", "commit_additions",
        "commit_deletions", "docs_mentions",
    ], issue_rows)
    print("METRICS_OK", json.dumps(summary, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

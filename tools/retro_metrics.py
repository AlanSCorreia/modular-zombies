#!/usr/bin/env python3
"""Gera métricas objetivas da retrospectiva do Bunker 13 v2.

Uso:
  python3 tools/retro_metrics.py
  python3 tools/retro_metrics.py --github --out metrics/aggregates/retrospective.md

Sem --github, usa o cache docs/planning/github-issues.json.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SUMMARY = ROOT / "metrics/aggregates/summary.json"
ISSUE_CACHE = ROOT / "docs/planning/github-issues.json"


def sh(*args: str) -> str:
    result = subprocess.run(
        args, cwd=ROOT, text=True, capture_output=True, check=False
    )
    return result.stdout.strip()


def count_lines(paths: list[Path]) -> int:
    total = 0
    for path in paths:
        try:
            total += len(path.read_text(encoding="utf-8", errors="ignore").splitlines())
        except OSError:
            pass
    return total


def files(pattern: str) -> list[Path]:
    return sorted(ROOT.glob(pattern))


def load_summary() -> dict:
    if not SUMMARY.is_file():
        return {}
    return json.loads(SUMMARY.read_text(encoding="utf-8"))


def load_issues(use_github: bool) -> list[dict]:
    if use_github:
        raw = sh(
            "gh", "issue", "list", "--state", "all", "--limit", "300",
            "--json", "number,title,state,createdAt,closedAt,labels,milestone",
        )
        if raw:
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                pass
    if not ISSUE_CACHE.is_file():
        return []
    data = json.loads(ISSUE_CACHE.read_text(encoding="utf-8"))
    return data.get("issues", [])


def issue_label_names(issue: dict) -> list[str]:
    labels = issue.get("labels", [])
    out = []
    for label in labels:
        if isinstance(label, dict):
            out.append(str(label.get("name", "")))
        else:
            out.append(str(label))
    return out



def parse_day(value: str) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def git_metrics() -> dict:
    dates = sh("git", "log", "--format=%cs").splitlines()
    subjects = sh("git", "log", "--format=%s").splitlines()
    authors = sh("git", "log", "--format=%an").splitlines()
    churn: Counter[str] = Counter()
    numstat = sh("git", "log", "--numstat", "--format=")
    for line in numstat.splitlines():
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        added, deleted, path = parts
        if added == "-" or deleted == "-":
            continue
        churn[path] += int(added) + int(deleted)
    return {
        "first": dates[-1] if dates else "",
        "last": dates[0] if dates else "",
        "commits": len(subjects),
        "authors": sorted(set(authors)),
        "fix_commits": sum(
            1 for s in subjects if s.lower().startswith(("fix:", "fix ", "hotfix"))
        ),
        "hotspots": churn.most_common(15),
    }


def content_metrics() -> dict:
    kinds: Counter[str] = Counter()
    for path in files("content/**/*.json"):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        kinds[str(data.get("kind", "?"))] += 1
    glbs = files("assets/models/**/*.glb")
    blends = files("source/blender/**/*.blend")
    assets_bytes = sum(p.stat().st_size for p in files("assets/**/*") if p.is_file())
    return {
        "json": len(files("content/**/*.json")),
        "kinds": dict(kinds),
        "glb": len(glbs),
        "blend": len(blends),
        "assets_mb": assets_bytes / 1048576.0,
    }


def decision_metrics() -> dict:
    decisions = 0
    work_entries = 0
    decision_path = ROOT / "docs/planning/19-decision-log.md"
    log_path = ROOT / "docs/planning/20-work-log.md"
    if decision_path.is_file():
        decisions = len(re.findall(
            r"^\| D-\d+", decision_path.read_text(encoding="utf-8"), re.M
        ))
    if log_path.is_file():
        work_entries = len(re.findall(
            r"^## ", log_path.read_text(encoding="utf-8"), re.M
        ))
    return {
        "decisions": decisions,
        "work_entries": work_entries,
        "docs": len(files("docs/planning/*.md")),
        "tags": sh("git", "tag", "--list").splitlines(),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--github", action="store_true",
                        help="consulta o GitHub em vez do cache local")
    parser.add_argument("--out", default="", help="arquivo Markdown de saída")
    args = parser.parse_args()

    summary = load_summary()
    issues = load_issues(args.github)
    git = git_metrics()
    content = content_metrics()
    decisions = decision_metrics()

    closed = [i for i in issues if str(i.get("state", "")).upper() == "CLOSED"]
    open_issues = [i for i in issues if str(i.get("state", "")).upper() == "OPEN"]
    labels = Counter()
    milestones = Counter()
    lead_days: list[float] = []
    for issue in closed:
        for label in issue_label_names(issue):
            labels[label] += 1
        ms = issue.get("milestone")
        if isinstance(ms, dict):
            ms = ms.get("title", "")
        if ms:
            milestones[str(ms)] += 1
        created = parse_day(str(issue.get("createdAt", "")))
        ended = parse_day(str(issue.get("closedAt", "")))
        if created and ended:
            lead_days.append((ended - created).total_seconds() / 86400.0)
    lead_avg = sum(lead_days) / len(lead_days) if lead_days else 0.0
    lead_sorted = sorted(lead_days)
    lead_median = (
        lead_sorted[len(lead_sorted) // 2] if lead_sorted else 0.0
    )

    src = files("src/**/*.gd")
    scenes = files("scenes/**/*.tscn") + files("scenes/**/*.tres")
    tests = files("tests/**/*.gd") + files("tests/**/*.sh")
    tools = files("tools/**/*.py") + files("tools/**/*.gd") + files("tools/**/*.sh")
    blender = files("source/blender/scripts/**/*.py")
    loc = {
        "src": count_lines(src),
        "scenes": count_lines(scenes),
        "tests": count_lines(tests),
        "tools": count_lines(tools),
        "blender": count_lines(blender),
    }

    ci = summary.get("ci", {})
    gates = [g for g in ci.get("gate_counts", {}) if g.endswith("_OK")]
    failures = {g: n for g, n in ci.get("gate_counts", {}).items()
                if g.endswith("_FAIL")}
    tokens = summary.get("tokens", {})
    token_work = sum(int(tokens.get(k, 0)) for k in
                     ("input", "output", "reasoning"))
    token_cache = int(tokens.get("cache_read", 0))
    closed_count = len(closed) or 1

    lines: list[str] = []
    add = lines.append
    add("# Retrospectiva quantitativa — Bunker 13 v2")
    add("")
    add(f"Gerado em {datetime.now().date().isoformat()}.")
    add("")
    add("## Escala")
    add("")
    add(f"- Período: **{git['first']} → {git['last']}**")
    add(f"- Commits: **{git['commits']}**")
    add(f"- Autores: {', '.join(git['authors']) or '—'}")
    add(f"- Issues: **{len(issues)}** ({len(closed)} fechadas, {len(open_issues)} abertas)")
    add(f"- Tags: {', '.join(decisions['tags']) or '—'}")
    add(f"- Docs de planejamento: **{decisions['docs']}**")
    add("")
    add("## Entrega")
    add("")
    add(f"- Lead time médio (issues fechadas): **{lead_avg:.1f} dias**")
    add(f"- Lead time mediano: **{lead_median:.1f} dias**")
    add(f"- Commits de correção (`fix:`): **{git['fix_commits']}** "
        f"({git['fix_commits'] * 100.0 / max(git['commits'], 1):.1f}% do total)")
    add(f"- Decisões registradas: **{decisions['decisions']}**")
    add(f"- Entradas no work log: **{decisions['work_entries']}**")
    add("")
    if milestones:
        add("### Issues fechadas por milestone")
        add("")
        add("| Milestone | Issues |")
        add("|---|---:|")
        for ms, count in milestones.most_common():
            add(f"| {ms} | {count} |")
        add("")
    if labels:
        add("### Labels mais usadas")
        add("")
        add("| Label | Issues |")
        add("|---|---:|")
        for label, count in labels.most_common(12):
            add(f"| `{label}` | {count} |")
        add("")
    add("## Código")
    add("")
    add("| Categoria | Arquivos | Linhas |")
    add("|---|---:|---:|")
    add(f"| GDScript src | {len(src)} | {loc['src']} |")
    add(f"| Cenas/resources | {len(scenes)} | {loc['scenes']} |")
    add(f"| Testes | {len(tests)} | {loc['tests']} |")
    add(f"| Ferramentas | {len(tools)} | {loc['tools']} |")
    add(f"| Scripts Blender | {len(blender)} | {loc['blender']} |")
    add("")
    add("### Hotspots de churn")
    add("")
    add("| Arquivo | Linhas alteradas |")
    add("|---|---:|")
    for path, changes in git["hotspots"]:
        add(f"| `{path}` | {changes} |")
    add("")
    add("## Conteúdo e assets")
    add("")
    add(f"- JSON de conteúdo: **{content['json']}**")
    for kind, count in sorted(content["kinds"].items()):
        add(f"  - `{kind}`: {count}")
    add(f"- GLBs: **{content['glb']}**")
    add(f"- Fontes `.blend`: **{content['blend']}**")
    add(f"- Tamanho de `assets/`: **{content['assets_mb']:.1f} MB**")
    add("")
    add("## Testes e CI")
    add("")
    add(f"- Gates `_OK` esperados: **{len(gates)}**")
    add(f"- Logs de CI no agregado: **{ci.get('logs', 0)}**")
    add(f"- Falhas históricas registradas: **{sum(failures.values())}**")
    if failures:
        add("  - " + ", ".join(f"{k}={v}" for k, v in sorted(failures.items())))
    add("")
    add("## Processo e IA")
    add("")
    add(f"- Sessões: **{summary.get('sessions', 0)}**")
    add(f"- Mensagens: **{summary.get('messages', 0)}**")
    add(f"- Tool calls: **{summary.get('tool_calls', 0)}**")
    add(f"- Tokens de trabalho (input+output+reasoning): **{token_work / 1_000_000:.1f} M**")
    add(f"- Cache read: **{token_cache / 1_000_000:.0f} M**")
    add(f"- Tokens de trabalho por issue fechada: **{token_work / closed_count / 1000:.0f} k**")
    add(f"- Ferramentas mais usadas: " + ", ".join(
        f"{k}={v}" for k, v in sorted(
            summary.get("tools", {}).items(), key=lambda item: -item[1]
        )[:8]
    ))
    add("")
    add("## Observações")
    add("")
    add("- Métricas de token/IA são de sessões locais e não substituem custo real de tempo.")
    add("- Lead time usa `createdAt`/`closedAt` do GitHub quando `--github` é usado;")
    add("  com cache local, os campos podem estar ausentes.")
    add("- Churn e LOC são indicadores de esforço, não de qualidade.")
    add("")

    output = "\n".join(lines)
    print(output)
    if args.out:
        out = ROOT / args.out
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(output, encoding="utf-8")
        print(f"\nRETRO_OK {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

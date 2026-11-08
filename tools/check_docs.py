#!/usr/bin/env python3
"""Valida e gera partes estruturais das docs do Bunker 13 v2.

Uso:
  python3 tools/check_docs.py              # valida (offline)
  python3 tools/check_docs.py --write      # regenera índice e gates
  python3 tools/check_docs.py --with-github
  python3 tools/check_docs.py --with-github --write-cache

Sem dependências externas. `--with-github` usa `gh`; o cache versionado
(`docs/planning/github-issues.json`) mantém o modo offline útil.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import date, datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs" / "planning"
KANBAN = ROOT / "KANBAN.md"
AGENTS = ROOT / "AGENTS.md"
CI = ROOT / "tests" / "ci.sh"
CACHE = DOCS / "github-issues.json"

FRONT_FIELDS = {"kind", "area", "status", "stage", "owner", "last_reviewed"}
KINDS = {"index", "planning", "reference", "log", "audit", "archive"}
AREAS = {"vision", "execution", "content", "history"}
STATUSES = {"active", "reference", "archive"}
OWNERS = {"docs", "gameplay", "assets", "infra"}
AREA_TITLES = {
    "vision": "Visão e arquitetura",
    "execution": "Execução e processo",
    "content": "Conteúdo, assets e sistemas",
    "history": "Histórico",
}
STALE_ACTIVE = (
    "Falta hands.glb",
    "--test headless",
    "faltam as mãos separadas",
    "Etapa 1 — Preparação concluída",
)

errors: list[str] = []
warnings: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def parse_front(path: Path) -> tuple[dict[str, str] | None, str]:
    text = path.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    meta: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip()] = value.strip()
    return meta, text[m.end():]


def title_of(body: str, path: Path) -> str:
    for line in body.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return path.stem


def check_front_matter() -> dict[Path, dict[str, str]]:
    docs: dict[Path, dict[str, str]] = {}
    for path in sorted(DOCS.rglob("*.md")):
        rel = path.relative_to(DOCS)
        meta, body = parse_front(path)
        if meta is None:
            err(f"{rel}: front matter ausente")
            continue
        docs[path] = meta
        missing = FRONT_FIELDS - set(meta)
        if missing:
            err(f"{rel}: campos ausentes {sorted(missing)}")
        for key, allowed in (
            ("kind", KINDS), ("area", AREAS), ("status", STATUSES),
            ("owner", OWNERS),
        ):
            if meta.get(key) and meta[key] not in allowed:
                err(f"{rel}: {key} inválido ({meta[key]})")
        try:
            stage = int(meta.get("stage", "-1"))
            if stage < 0 or stage > 8:
                err(f"{rel}: stage fora de 0..8")
        except ValueError:
            err(f"{rel}: stage não numérico")
        try:
            reviewed = date.fromisoformat(meta.get("last_reviewed", ""))
            age = (date.today() - reviewed).days
            if meta.get("status") == "active" and age > 60:
                warn(f"{rel}: revisão ativa com {age} dias")
            elif meta.get("status") == "reference" and age > 180:
                warn(f"{rel}: referência com {age} dias")
        except ValueError:
            err(f"{rel}: last_reviewed inválido")
        if "archive" in rel.parts and meta.get("status") != "archive":
            err(f"{rel}: doc em archive/ precisa status: archive")
        if meta.get("status") == "archive" and "archive" not in rel.parts:
            err(f"{rel}: status archive fora de archive/")
        if title_of(body, path) == path.stem:
            warn(f"{rel}: sem título '# '")
    return docs


def check_links() -> None:
    for path in sorted(DOCS.rglob("*.md")):
        rel = path.relative_to(DOCS)
        text = path.read_text(encoding="utf-8")
        for match in re.finditer(r"\[[^\]]*\]\(([^)]+)\)", text):
            target = match.group(1).strip()
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            target = target.split("#", 1)[0]
            if not target:
                continue
            if not (path.parent / target).resolve().exists():
                err(f"{rel}: link quebrado -> {match.group(1)}")


def generated_index(docs: dict[Path, dict[str, str]]) -> str:
    grouped: dict[str, list[tuple[str, str, str]]] = {
        area: [] for area in AREA_TITLES
    }
    for path, meta in docs.items():
        if meta.get("kind") == "index":
            continue
        rel = path.relative_to(DOCS).as_posix()
        _, body = parse_front(path)
        grouped.setdefault(meta.get("area", "history"), []).append(
            (rel, title_of(body, path), meta.get("status", ""))
        )
    lines: list[str] = []
    for area, title in AREA_TITLES.items():
        items = sorted(grouped.get(area, []), key=lambda item: item[0])
        if not items:
            continue
        lines.append(f"### {title}")
        lines.append("")
        lines.append("| Documento | Título |")
        lines.append("|---|---|")
        for rel, title_text, status in items:
            suffix = " _(arquivo)_" if status == "archive" else ""
            lines.append(f"| [`{rel}`]({rel}) | {title_text}{suffix} |")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def replace_block(path: Path, start_marker: str, end_marker: str,
                  content: str, write: bool) -> None:
    text = path.read_text(encoding="utf-8")
    if start_marker not in text or end_marker not in text:
        err(f"{path.relative_to(ROOT)}: marcadores {start_marker} ausentes")
        return
    pattern = re.compile(
        re.escape(start_marker) + r".*?" + re.escape(end_marker), re.S
    )
    block = f"{start_marker}\n{content}{end_marker}"
    if write:
        path.write_text(pattern.sub(block, text), encoding="utf-8")
        return
    current = pattern.search(text)
    if current is None or current.group(0) != block.rstrip("\n"):
        err(f"{path.relative_to(ROOT)}: bloco gerado desatualizado "
            f"(rode --write)")


def check_index(docs: dict[Path, dict[str, str]], write: bool) -> None:
    readme = DOCS / "README.md"
    replace_block(readme, "<!-- INDEX:START -->", "<!-- INDEX:END -->",
                  generated_index(docs), write)


def ci_gates() -> list[str]:
    text = CI.read_text(encoding="utf-8")
    match = re.search(r'^GATES="([^"]+)"', text, re.M)
    if match:
        return sorted(set(match.group(1).split()))
    for path in (ROOT / "tests").glob("*.gd"):
        text += "\n" + path.read_text(encoding="utf-8")
    return sorted(set(re.findall(r"\b([A-Z][A-Z0-9_]*_OK)\b", text)))


def check_gates(write: bool) -> None:
    gates = ci_gates()
    testing = DOCS / "08-testing-strategy.md"
    content = ", ".join(f"`{gate}`" for gate in gates) + "\n\n"
    replace_block(testing, "<!-- GATES:START -->", "<!-- GATES:END -->",
                  content, write)

    agents_text = AGENTS.read_text(encoding="utf-8")
    m = re.search(r"CI esperado:(.+)", agents_text)
    if not m:
        err("AGENTS.md: linha 'CI esperado:' ausente")
        return
    agents_gates = sorted(set(re.findall(r"\b([A-Z][A-Z0-9_]*_OK)\b", m.group(1))))
    if gates != agents_gates:
        err(f"AGENTS.md: gates divergem do ci.sh "
            f"(faltam={sorted(set(gates) - set(agents_gates))}, "
            f"sobram={sorted(set(agents_gates) - set(gates))})")

    testing_text = testing.read_text(encoding="utf-8")
    block = re.search(r"<!-- GATES:START -->(.*?)<!-- GATES:END -->",
                      testing_text, re.S)
    if block:
        doc_gates = sorted(set(re.findall(r"\b([A-Z][A-Z0-9_]*_OK)\b",
                                          block.group(1))))
        if doc_gates != gates:
            err("08-testing-strategy.md: gates divergem do ci.sh")


def check_kanban(docs: dict[Path, dict[str, str]]) -> int:
    text = KANBAN.read_text(encoding="utf-8")
    stage_match = re.search(r"\*\*Etapa ativa:\*\*\s*(\d+)", text)
    if not stage_match:
        err("KANBAN.md: 'Etapa ativa' ausente")
        return 0
    stage = int(stage_match.group(1))

    stages = [int(n) for n in re.findall(r"^# Etapa (\d+) —", text, re.M)]
    if stages != list(range(1, 9)):
        err(f"KANBAN.md: etapas inesperadas {stages}")

    heading = f"# Etapa {stage} —"
    start = text.find(heading)
    if start < 0:
        err(f"KANBAN.md: seção da etapa {stage} ausente")
        return stage
    next_heading = text.find("\n# Etapa ", start + len(heading))
    section = text[start:next_heading if next_heading >= 0 else len(text)]

    ready_match = re.search(r"### Ready\n(.*?)(?=### )", section, re.S)
    doing_match = re.search(r"### Doing\n(.*?)(?=### )", section, re.S)
    ready = ready_match.group(1) if ready_match else ""
    doing = doing_match.group(1) if doing_match else ""

    doing_items = [line for line in doing.splitlines() if line.startswith("- [ ]")]
    if len(doing_items) > 1:
        err(f"KANBAN.md: {len(doing_items)} itens em Doing (máx. 1)")
    for item in doing_items:
        if not re.search(r"issues/\d+", item):
            err("KANBAN.md: item em Doing sem issue")

    ready_items = [line for line in ready.splitlines() if line.startswith("- [ ]")]
    if len(ready_items) > 5:
        warn(f"KANBAN.md: {len(ready_items)} itens em Ready (recomendado <= 5)")
    for item in ready_items:
        if not re.search(r"issues/\d+", item):
            warn(f"KANBAN.md: Ready sem issue -> {item[6:70]}")

    next_match = re.search(r"\*\*Próximo:\*\*\s*(.+)", text)
    if not next_match:
        err("KANBAN.md: linha 'Próximo:' ausente")
    else:
        next_issues = re.findall(r"(?:issues/|#)(\d+)", next_match.group(1))
        if not next_issues:
            err("KANBAN.md: 'Próximo' sem issue")
        if ready_items:
            top_issues = re.findall(r"issues/(\d+)", ready_items[0])
            if top_issues and next_issues and top_issues[0] != next_issues[0]:
                err("KANBAN.md: 'Próximo' não bate com o topo de Ready")
            if not top_issues:
                err("KANBAN.md: topo de Ready sem issue")
    return stage


def check_work_log() -> None:
    path = DOCS / "20-work-log.md"
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if len(lines) > 240:
        err(f"20-work-log.md: {len(lines)} linhas (máx. 240)")
    elif len(lines) > 160:
        warn(f"20-work-log.md: {len(lines)} linhas (rotacionar?)")
    headings = re.findall(r"^## (\d{4}-\d{2}-\d{2}) — (.+)$", text, re.M)
    if len(headings) < 1:
        err("20-work-log.md: sem seções datadas")
    dates = [date.fromisoformat(item[0]) for item in headings]
    if dates != sorted(dates, reverse=True):
        err("20-work-log.md: datas fora de ordem decrescente")
    seen: set[str] = set()
    for _, title in headings:
        found = re.findall(r"issue #(\d+)", title)
        for issue in found:
            if issue in seen:
                err(f"20-work-log.md: issue #{issue} duplicada")
            seen.add(issue)


def check_decisions() -> None:
    path = DOCS / "19-decision-log.md"
    text = path.read_text(encoding="utf-8")
    rows = []
    for line in text.splitlines():
        if not line.startswith("| D-"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 4:
            err(f"19-decision-log.md: linha incompleta -> {line[:60]}")
            continue
        try:
            number = int(cells[0][2:])
        except ValueError:
            err(f"19-decision-log.md: ID inválido -> {cells[0]}")
            continue
        rows.append((number, cells))
    numbers = [row[0] for row in rows]
    if numbers != sorted(numbers, reverse=True):
        err("19-decision-log.md: decisões fora de ordem decrescente")
    if sorted(numbers) != list(range(1, len(numbers) + 1)):
        err("19-decision-log.md: IDs fora de sequência D-001..")
    for number, cells in rows:
        if not re.match(r"\d{4}-\d{2}-\d{2}$", cells[1]):
            err(f"19-decision-log.md: D-{number:03d} data inválida")
        if not cells[2] or not cells[3]:
            err(f"19-decision-log.md: D-{number:03d} decisão/justificativa vazia")


def check_backlog_ids() -> None:
    path = DOCS / "06-backlog.md"
    text = path.read_text(encoding="utf-8")
    ids = re.findall(r"^\|\s*ETAPA(\d+)\.(\d+)", text, re.M)
    if len(ids) != len(set(ids)):
        seen: set[tuple[str, str]] = set()
        for item in ids:
            if item in seen:
                err(f"06-backlog.md: ID duplicado ETAPA{item[0]}.{item[1]}")
            seen.add(item)



def check_duplicate_lines() -> None:
    seen: dict[str, set[str]] = {}
    for path in sorted(DOCS.rglob("*.md")):
        meta, _ = parse_front(path)
        if meta is None or meta.get("status") == "archive":
            continue
        rel = path.relative_to(DOCS).as_posix()
        for line in path.read_text(encoding="utf-8").splitlines():
            text = line.strip()
            if len(text) < 70 or text.startswith(("|", "```", "<!--", "#", "- [")):
                continue
            seen.setdefault(text, set()).add(rel)
    for text, files in seen.items():
        if len(files) >= 3:
            warn(f"linha repetida em {len(files)} docs: {text[:70]}...")


def check_stale() -> None:
    for path in sorted(DOCS.rglob("*.md")):
        meta, _ = parse_front(path)
        if meta is None or meta.get("status") == "archive":
            continue
        text = path.read_text(encoding="utf-8")
        for phrase in STALE_ACTIVE:
            if phrase in text:
                err(f"{path.relative_to(DOCS)}: frase obsoleta -> {phrase}")


def load_github(with_github: bool, write_cache: bool) -> dict[int, dict] | None:
    data: dict | None = None
    if with_github:
        try:
            out = subprocess.run(
                ["gh", "issue", "list", "--state", "all", "--limit", "200",
                 "--json", "number,title,state,labels,milestone"],
                check=True, capture_output=True, text=True, cwd=ROOT,
            ).stdout
            raw = json.loads(out)
            normalized = []
            for issue in raw:
                labels = [
                    label.get("name", "") if isinstance(label, dict) else label
                    for label in issue.get("labels", [])
                ]
                milestone = issue.get("milestone") or {}
                normalized.append({
                    "number": int(issue["number"]),
                    "title": issue.get("title", ""),
                    "state": issue.get("state", ""),
                    "labels": labels,
                    "milestone": milestone.get("title", ""),
                })
            normalized.sort(key=lambda item: item["number"])
            data = {"generated_at": date.today().isoformat(),
                    "issues": normalized}
            if write_cache:
                CACHE.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n",
                                 encoding="utf-8")
        except (subprocess.CalledProcessError, FileNotFoundError) as exc:
            err(f"GitHub: falha ao consultar issues ({exc})")
            return None
    elif CACHE.exists():
        data = json.loads(CACHE.read_text(encoding="utf-8"))
    else:
        warn("GitHub: cache ausente; checagens de issue ignoradas")
        return None

    issues: dict[int, dict] = {}
    for issue in data.get("issues", []):
        labels = [
            label.get("name", "") if isinstance(label, dict) else label
            for label in issue.get("labels", [])
        ]
        milestone = issue.get("milestone") or {}
        issues[int(issue["number"])] = {
            "title": issue.get("title", ""),
            "state": issue.get("state", ""),
            "labels": labels,
            "milestone": milestone.get("title", "") if isinstance(milestone, dict) else milestone,
        }
    return issues


def check_github(issues: dict[int, dict] | None, stage: int) -> None:
    if issues is None:
        return
    text = KANBAN.read_text(encoding="utf-8")
    referenced = {int(n) for n in re.findall(r"issues/(\d+)", text)}
    for number, info in issues.items():
        if info["state"] == "OPEN" and number not in referenced:
            err(f"GitHub: issue aberta #{number} não aparece no KANBAN")
        if info["state"] == "OPEN" and not any(
            label.startswith("etapa:") for label in info["labels"]
        ):
            warn(f"GitHub: issue aberta #{number} sem label etapa:*")
        if info["state"] == "CLOSED" and number in referenced:
            # Fechada pode aparecer em Done; só falha se estiver em Ready/Doing.
            pass
    for number in sorted(referenced):
        if number not in issues:
            err(f"KANBAN: referência a issue inexistente #{number}")
    next_match = re.search(r"\*\*Próximo:\*\*.*?issues/(\d+)", text)
    if next_match:
        number = int(next_match.group(1))
        if issues.get(number, {}).get("state") != "OPEN":
            err(f"KANBAN: próximo item #{number} não está aberto")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true",
                        help="regenera índice e bloco de gates")
    parser.add_argument("--with-github", action="store_true",
                        help="consulta issues reais via gh")
    parser.add_argument("--write-cache", action="store_true",
                        help="atualiza docs/planning/github-issues.json")
    args = parser.parse_args()

    docs = check_front_matter()
    check_links()
    check_index(docs, args.write)
    check_gates(args.write)
    stage = check_kanban(docs)
    check_work_log()
    check_decisions()
    check_backlog_ids()
    check_duplicate_lines()
    check_stale()
    issues = load_github(args.with_github, args.write_cache)
    check_github(issues, stage)

    for warning in warnings:
        print(f"WARN  {warning}")
    for error in errors:
        print(f"FAIL  {error}")
    if errors:
        print(f"\nDOCS_FAIL {len(errors)} erro(s), {len(warnings)} aviso(s)")
        return 1
    print(f"DOCS_OK {len(docs)} docs, {len(warnings)} aviso(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

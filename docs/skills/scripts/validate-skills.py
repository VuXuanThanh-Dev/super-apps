#!/usr/bin/env python3
"""Validate every .claude/skills/<name>/SKILL.md against the official format.

Rules (sources in docs/skills/RESEARCH.md, checked 2026-09-28):
- SKILL.md exists and starts with YAML frontmatter (--- ... ---).
- name: 1-64 chars, [a-z0-9-], no leading/trailing '-', no '--', equals the folder name
  (Agent Skills spec). Not 'synced', not starting with 'anthropic-skills' (Claude Code).
- description: present, 1-1024 chars (spec); description + when_to_use <= 1536 (Claude Code).
- compatibility: <= 500 chars if present.
- Only known frontmatter fields (Claude Code list + Agent Skills spec).
- Body under 500 lines (Claude Code recommendation) -> warning only.
- Relative Markdown links from SKILL.md point to files that exist.
- If a skill has LICENSE/LICENSE.txt, SKILL.md must contain a credit line ("Source:").
Usage: python3 docs/skills/scripts/validate-skills.py [skills_dir]
Exit code 1 if any error.
"""
import re
import sys
from pathlib import Path

import yaml

ALLOWED = {
    "name", "description", "when_to_use", "argument-hint", "arguments",
    "disable-model-invocation", "user-invocable", "allowed-tools", "disallowed-tools",
    "model", "effort", "context", "agent", "background", "hooks", "paths", "shell",
    "metadata", "license", "compatibility",
}
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
LINK_RE = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")


def check(skill_dir: Path) -> tuple[list[str], list[str]]:
    errors, warns = [], []
    f = skill_dir / "SKILL.md"
    if not f.is_file():
        return [f"{skill_dir.name}: missing SKILL.md"], warns
    text = f.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        return [f"{skill_dir.name}: no YAML frontmatter at top of SKILL.md"], warns
    try:
        fm = yaml.safe_load(m.group(1)) or {}
    except yaml.YAMLError as e:
        return [f"{skill_dir.name}: invalid YAML: {e}"], warns
    body = m.group(2)
    name = fm.get("name")
    if not isinstance(name, str) or not NAME_RE.match(name) or len(name) > 64:
        errors.append(f"{skill_dir.name}: bad name {name!r}")
    elif name != skill_dir.name:
        errors.append(f"{skill_dir.name}: name {name!r} != folder name")
    elif name == "synced" or name.startswith("anthropic-skills"):
        errors.append(f"{skill_dir.name}: reserved name")
    desc = fm.get("description")
    if not isinstance(desc, str) or not desc.strip():
        errors.append(f"{skill_dir.name}: description missing")
    else:
        if len(desc) > 1024:
            errors.append(f"{skill_dir.name}: description {len(desc)} > 1024 chars")
        total = len(desc) + len(fm.get("when_to_use") or "")
        if total > 1536:
            errors.append(f"{skill_dir.name}: description+when_to_use {total} > 1536")
        if "not" not in desc.lower():
            warns.append(f"{skill_dir.name}: description has no 'when NOT to use' part")
    comp = fm.get("compatibility")
    if comp is not None and len(str(comp)) > 500:
        errors.append(f"{skill_dir.name}: compatibility > 500 chars")
    for key in fm:
        if key not in ALLOWED:
            errors.append(f"{skill_dir.name}: unknown frontmatter field {key!r}")
    lines = body.count("\n")
    if lines > 500:
        warns.append(f"{skill_dir.name}: SKILL.md body has {lines} lines (> 500)")
    for link in LINK_RE.findall(body):
        if "://" in link or link.startswith("mailto:"):
            continue
        if not (skill_dir / link).exists():
            errors.append(f"{skill_dir.name}: broken relative link {link}")
    has_license = any((skill_dir / n).exists() for n in ("LICENSE", "LICENSE.txt", "LICENSE.md"))
    if has_license and "Source:" not in body[:1500]:
        errors.append(f"{skill_dir.name}: has a LICENSE file but no 'Source:' credit near the top")
    return errors, warns


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[3] / ".claude/skills"
    dirs = sorted(p for p in root.iterdir() if p.is_dir())
    all_err = 0
    for d in dirs:
        errs, warns = check(d)
        status = "OK  " if not errs else "FAIL"
        print(f"{status} {d.name}")
        for e in errs:
            print(f"   ERROR {e}")
        for w in warns:
            print(f"   warn  {w}")
        all_err += len(errs)
    print(f"\n{len(dirs)} skills, {all_err} errors")
    return 1 if all_err else 0


if __name__ == "__main__":
    sys.exit(main())

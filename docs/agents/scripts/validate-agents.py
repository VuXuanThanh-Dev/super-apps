#!/usr/bin/env python3
"""Validate Claude Code subagent files in .claude/agents/.

Checks follow the official format (https://code.claude.com/docs/en/sub-agents,
checked 2026-09-28) plus the rules of this repo (docs/agents/PLAN.md).
Usage: python3 docs/agents/scripts/validate-agents.py [agents_dir]
Exit code 0 = all good, 1 = at least one error.
"""
import re
import sys
from pathlib import Path

import yaml

KNOWN_TOOLS = {
    "Agent", "AskUserQuestion", "Bash", "Edit", "Glob", "Grep", "LSP", "Monitor",
    "NotebookEdit", "Read", "Skill", "TaskCreate", "TaskGet", "TaskList", "TaskUpdate",
    "TodoWrite", "WebFetch", "WebSearch", "Write",
}
MODELS = {"sonnet", "opus", "haiku", "fable", "inherit"}
COLORS = {"red", "blue", "green", "yellow", "purple", "orange", "pink", "cyan"}
KNOWN_FIELDS = {
    "name", "description", "tools", "disallowedTools", "model", "permissionMode",
    "maxTurns", "skills", "mcpServers", "hooks", "memory", "background", "effort",
    "isolation", "color", "omitClaudeMd", "initialPrompt", "experimental",
}
WRITE_TOOLS = {"Write", "Edit", "NotebookEdit"}
# Agents that must stay read-only (repo design rule, see PLAN.md).
READ_ONLY = {
    "code-reviewer", "security-reviewer", "ba-requirements-challenger",
    "estimation-and-planning", "intern-mentor", "pr-and-commit-writer", "english-coach",
}
MAX_DESC = 450


def split_frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        return None, None
    return m.group(1), m.group(2)


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".claude/agents")
    errors, rows, names = [], [], set()
    for p in sorted(root.iterdir()):
        if p.is_dir() or p.suffix != ".md":
            errors.append(f"{p}: only agent .md files may live in {root}")
    for p in sorted(root.glob("*.md")):
        fm_text, body = split_frontmatter(p.read_text(encoding="utf-8"))
        if fm_text is None:
            errors.append(f"{p.name}: missing YAML frontmatter")
            continue
        try:
            fm = yaml.safe_load(fm_text)
        except yaml.YAMLError as e:
            errors.append(f"{p.name}: YAML error: {e}")
            continue
        name, desc = fm.get("name"), fm.get("description")
        for field in fm:
            if field not in KNOWN_FIELDS:
                errors.append(f"{p.name}: unknown field '{field}'")
        if not name or not isinstance(name, str):
            errors.append(f"{p.name}: 'name' is required")
            continue
        if name.startswith("-") or ":" in name or not re.fullmatch(r"[a-z0-9-]+", name):
            errors.append(f"{p.name}: bad name '{name}' (kebab-case, no ':' or leading '-')")
        if name != p.stem:
            errors.append(f"{p.name}: name '{name}' must match file name")
        if name in names:
            errors.append(f"{p.name}: duplicate name")
        names.add(name)
        if not desc or not isinstance(desc, str):
            errors.append(f"{name}: 'description' is required")
            desc = ""
        if len(desc) > MAX_DESC:
            errors.append(f"{name}: description {len(desc)} chars > {MAX_DESC}")
        if "Not for" not in desc:
            errors.append(f"{name}: description must say 'Not for ...' (overlap guard)")
        if "Example" not in desc:
            errors.append(f"{name}: description must contain example triggers")
        tools = fm.get("tools")
        if tools is None:
            errors.append(f"{name}: 'tools' must be set (least privilege; omitted = all tools)")
            tool_list = []
        else:
            tool_list = [t.strip() for t in (tools.split(",") if isinstance(tools, str) else tools)]
        for t in tool_list:
            if t not in KNOWN_TOOLS:
                errors.append(f"{name}: unknown tool '{t}'")
        if "Agent" in tool_list:
            errors.append(f"{name}: must not spawn subagents (remove 'Agent')")
        if name in READ_ONLY and WRITE_TOOLS & set(tool_list):
            errors.append(f"{name}: read-only agent has write tools {WRITE_TOOLS & set(tool_list)}")
        model = fm.get("model")
        if model not in MODELS and not str(model).startswith("claude-"):
            errors.append(f"{name}: bad model '{model}'")
        if fm.get("color") and fm["color"] not in COLORS:
            errors.append(f"{name}: bad color '{fm['color']}'")
        for section in ("## Steps", "## Output format", "## Done means"):
            if section not in body and not (section == "## Steps" and "## Setup" in body):
                errors.append(f"{name}: body is missing '{section}'")
        rows.append((name, model, ", ".join(tool_list), len(desc)))

    width = max((len(r[0]) for r in rows), default=4)
    print(f"{'agent'.ljust(width)}  model    desc  tools")
    for n, m, t, d in rows:
        print(f"{n.ljust(width)}  {str(m).ljust(7)}  {str(d).rjust(4)}  {t}")
    print(f"\n{len(rows)} agent files checked, {len(errors)} error(s)")
    for e in errors:
        print("ERROR:", e)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())

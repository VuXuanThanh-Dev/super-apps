#!/usr/bin/env python3
"""Inject real code and real program output into the Markdown chapters.

Markers (the fenced block right after a marker is replaced):
  <!-- include: examples/Ch01.Hello/Program.cs -->
  <!-- output: examples/Ch01.Hello -->          (reads <dir>/output.txt)
Paths are relative to the Markdown file.
Usage: tools/embed.py vol1-basics [vol2-intermediate ...]
"""
import pathlib, re, sys

LANG = {".cs": "csharp", ".csproj": "xml", ".json": "json", ".sh": "bash",
        ".http": "http", ".yml": "yaml", ".yaml": "yaml", ".txt": "text", "Dockerfile": "dockerfile",
        ".ts": "typescript", ".java": "java", ".props": "xml"}
MARK = re.compile(r"^<!-- (include|output): (\S+) -->\n(```[^\n]*\n.*?^```\n)?",
                  re.M | re.S)

def lang_of(p: pathlib.Path) -> str:
    return LANG.get(p.name) or LANG.get(p.suffix, "text")

def process(md: pathlib.Path) -> int:
    text = md.read_text(encoding="utf-8")
    errors = 0
    def repl(m):
        nonlocal errors
        kind, rel = m.group(1), m.group(2)
        target = (md.parent / rel)
        if kind == "output":
            target = target / "output.txt"
            lang = "text"
        else:
            lang = lang_of(target)
        if not target.exists():
            print(f"MISSING {md}: {target}", file=sys.stderr); errors += 1
            return m.group(0)
        body = target.read_text(encoding="utf-8").rstrip("\n")
        fence = "````" if "```" in body else "```"
        return f"<!-- {kind}: {rel} -->\n{fence}{lang}\n{body}\n{fence}\n"
    new = MARK.sub(repl, text)
    if new != text:
        md.write_text(new, encoding="utf-8"); print(f"updated {md}")
    return errors

def main():
    root = pathlib.Path(__file__).resolve().parent.parent
    errs = 0
    for vol in sys.argv[1:]:
        for md in sorted((root / vol).rglob("*.md")):
            if "/bin/" in str(md) or "/obj/" in str(md) or "node_modules" in str(md):
                continue
            errs += process(md)
    sys.exit(1 if errs else 0)

if __name__ == "__main__":
    main()

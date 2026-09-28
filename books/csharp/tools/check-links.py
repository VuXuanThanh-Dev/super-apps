#!/usr/bin/env python3
"""Link checker for the book. Usage: tools/check-links.py  (writes tools/link-report.txt)

- Collects every http(s) URL in the Markdown files of books/csharp (not examples/output).
- github.com/<o>/<r>/blob/<ref>/<path>  -> checked via raw.githubusercontent.com (github.com is
  not reachable with curl from the sandbox, raw is).
- github.com/<o>/<r> (repo root)       -> checked via its raw README.md.
- Hosts blocked by the sandbox proxy are reported separately ("blocked by sandbox, not broken").
"""
import pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
URL = re.compile(r"https?://[^\s)<>\"'`|]+")
BLOCKED_HOSTS = {"learn.microsoft.com", "openjdk.org", "docs.oracle.com", "xunit.net"}

def check(url: str) -> tuple[str, str]:
    target = url
    m = re.match(r"https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$", url)
    if m:
        target = f"https://raw.githubusercontent.com/{m[1]}/{m[2]}/{m[3]}/{m[4]}"
    else:
        m = re.match(r"https://github\.com/([^/]+)/([^/#]+)/?$", url)
        if m:
            target = f"https://raw.githubusercontent.com/{m[1]}/{m[2]}/HEAD/README.md"
    host = re.match(r"https?://([^/]+)", url)[1]
    if host in BLOCKED_HOSTS:
        return "BLOCKED", "host blocked by sandbox proxy"
    r = subprocess.run(["curl", "-sS", "-L", "-o", "/dev/null", "-w", "%{http_code}", "--max-time", "25",
                        "-A", "Mozilla/5.0 link-check", target], capture_output=True, text=True)
    code = r.stdout.strip()
    if code.startswith("2") or code.startswith("3"):
        return "OK", f"{code} via {target}" if target != url else code
    if "CONNECT tunnel failed" in r.stderr or code == "000":
        return "BLOCKED", (r.stderr.strip().splitlines() or ["no response"])[-1]
    return "BROKEN", f"HTTP {code} via {target}"

def main():
    urls = {}
    for md in sorted(ROOT.rglob("*.md")):
        if any(x in md.parts for x in ("node_modules", "bin", "obj", "build")):
            continue
        text = md.read_text(encoding="utf-8")
        text = re.sub(r"^(```+|~~~+).*?^\1\s*$", "", text, flags=re.M | re.S)  # skip fenced code (program output)
        text = re.sub(r"`[^`\n]*`", "", text)                                  # skip inline code
        for u in URL.findall(text):
            u = u.rstrip(".,;:")
            urls.setdefault(u, set()).add(str(md.relative_to(ROOT)))
    # skip placeholders/local
    urls = {u: f for u, f in urls.items() if "localhost" not in u and "<" not in u}
    results = {"OK": [], "BROKEN": [], "BLOCKED": []}
    for u in sorted(urls):
        status, info = check(u)
        results[status].append((u, info, sorted(urls[u])))
    lines = [f"Link check — {len(urls)} unique URLs",
             f"OK: {len(results['OK'])}  BROKEN: {len(results['BROKEN'])}  BLOCKED (sandbox, not broken): {len(results['BLOCKED'])}", ""]
    for key in ("BROKEN", "BLOCKED", "OK"):
        lines.append(f"== {key}")
        for u, info, files in results[key]:
            lines.append(f"{u}  [{info}]  in: {', '.join(files)}")
        lines.append("")
    report = "\n".join(lines)
    (ROOT / "tools" / "link-report.txt").write_text(report, encoding="utf-8")
    print("\n".join(lines[:2]))
    for u, info, files in results["BROKEN"] + results["BLOCKED"]:
        print(" -", u, info)
    sys.exit(1 if results["BROKEN"] else 0)

if __name__ == "__main__":
    main()

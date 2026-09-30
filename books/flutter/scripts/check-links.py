#!/usr/bin/env python3
"""Kiểm tra mọi link http(s) trong Markdown của bộ sách Flutter (dựa trên script của bộ sách React Native).

Sandbox chặn một số host (github.com qua curl, docs.flutter.dev, dart.dev...), nên:
- github.com/<o>/<r>/blob|tree/<branch>/<path> → kiểm tra bản raw trên raw.githubusercontent.com
  (với tree/: kiểm tra qua GitHub không được → dùng `git ls-remote` cho repo).
- github.com/<o>/<r>[/pull/<n>] → `git ls-remote` (repo, và ref của pull request).
- www.npmjs.com/package/<p> → registry.npmjs.org/<p>.
- Các host đã biết bị chặn → báo "BLOCKED (sandbox)", KHÔNG tính là link hỏng.
Kết quả: OK / BROKEN / BLOCKED. Thoát mã 1 nếu có BROKEN.
"""
import re
import subprocess
import sys
import urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BLOCKED_HOSTS = {
    # Bị chặn trong sandbox (kiểm tra 2026-09-30) — không phải link hỏng:
    "docs.flutter.dev", "api.flutter.dev", "flutter.dev", "dart.dev", "www.gstatic.com", "fonts.gstatic.com",
    "api.dictionaryapi.dev", "docs.github.com", "codemagic.io", "m3.material.io",
}
URL_RE = re.compile(r"https?://[^\s)<>\]\"'`]+")


def curl_ok(url: str) -> tuple[bool, str]:
    r = subprocess.run(["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}", "-L", "--max-time", "20", url],
                       capture_output=True, text=True)
    code = r.stdout.strip() or "000"
    return code.startswith("2"), code


def git_ls_remote(repo: str, ref: str | None = None) -> bool:
    args = ["git", "ls-remote", f"https://github.com/{repo}"]
    if ref:
        args.append(ref)
    r = subprocess.run(args, capture_output=True, text=True, timeout=60)
    return r.returncode == 0 and (ref is None or bool(r.stdout.strip()))


def check(url: str) -> tuple[str, str]:
    u = urllib.parse.urlparse(url.rstrip(".,;:"))
    host = u.netloc
    if not host or host.endswith(".example") or host.endswith("example.com") or host == "evil.com" or "…" in url:
        return "SKIP", "URL ví dụ trong nội dung, không phải nguồn"
    if host in BLOCKED_HOSTS:
        return "BLOCKED", "host bị chặn trong sandbox"
    if host == "github.com":
        parts = [p for p in u.path.split("/") if p]
        if len(parts) >= 5 and parts[2] == "blob":
            raw = f"https://raw.githubusercontent.com/{parts[0]}/{parts[1]}/{'/'.join(parts[3:])}"
            ok, code = curl_ok(raw)
            return ("OK" if ok else "BROKEN"), f"raw {code}"
        if len(parts) >= 4 and parts[2] == "pull":
            ok = git_ls_remote(f"{parts[0]}/{parts[1]}", f"refs/pull/{parts[3]}/head")
            return ("OK" if ok else "BROKEN"), "git ls-remote pull ref"
        if len(parts) >= 2:
            ok = git_ls_remote(f"{parts[0]}/{parts[1]}")
            return ("OK" if ok else "BROKEN"), "git ls-remote repo"
    if host == "www.npmjs.com" and u.path.startswith("/package/"):
        ok, code = curl_ok("https://registry.npmjs.org/" + u.path[len("/package/"):])
        return ("OK" if ok else "BROKEN"), f"registry {code}"
    ok, code = curl_ok(url)
    if ok:
        return "OK", code
    if code in ("000", "403"):
        return "BLOCKED", f"http {code} (có thể do proxy sandbox)"
    return "BROKEN", code


def main() -> int:
    skip = {"node_modules", "build", ".dart_tool"}
    files = sorted(p for p in ROOT.rglob("*.md") if not skip.intersection(p.parts))
    # 1) Link tương đối trong Markdown: file đích phải tồn tại.
    local_re = re.compile(r"\]\((?!https?://|#|mailto:)([^)\s]+)\)")
    missing = []
    for f in files:
        text = re.sub(r"```.*?```", "", f.read_text(encoding="utf-8"), flags=re.S)  # bỏ khối code
        for m in local_re.finditer(text):
            target = (f.parent / m.group(1).split("#")[0]).resolve()
            if not target.exists():
                missing.append(f"{f.relative_to(ROOT)} → {m.group(1)}")
    for x in missing:
        print(f"BROKEN   (link tương đối) {x}")
    print(f"Link tương đối: {'OK' if not missing else str(len(missing)) + ' hỏng'}")
    urls: dict[str, list[str]] = {}
    for f in files:
        for m in URL_RE.finditer(f.read_text(encoding="utf-8")):
            urls.setdefault(m.group(0).rstrip(".,;:"), []).append(str(f.relative_to(ROOT)))
    counts = {"OK": 0, "BROKEN": 0, "BLOCKED": 0, "SKIP": 0}
    for url in sorted(urls):
        status, note = check(url)
        counts[status] += 1
        if status not in ("OK", "SKIP"):
            print(f"{status:8} {url}  [{note}]  ← {', '.join(sorted(set(urls[url])))}")
    print(f"\nTổng {len(urls)} link: OK={counts['OK']} BROKEN={counts['BROKEN']} BLOCKED={counts['BLOCKED']} SKIP(ví dụ)={counts['SKIP']}")
    return 1 if counts["BROKEN"] or missing else 0


if __name__ == "__main__":
    sys.exit(main())

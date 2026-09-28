#!/usr/bin/env bash
# Build one PDF per volume: Markdown (source of truth) -> pandoc HTML -> Chromium (Playwright) PDF.
# Then check Vietnamese accents in each PDF with pdftotext.
# Requirements: pandoc, Node.js, `npm ci` in tools/pdf, Chromium for Playwright, fonts Noto Serif/Sans/Sans Mono.
set -euo pipefail
export LANG=C.UTF-8 LC_ALL=C.UTF-8
ROOT="$(cd "$(dirname "$0")/.." && pwd)"       # books/csharp
PDFDIR="$ROOT/tools/pdf"
BUILD="$PDFDIR/build"
mkdir -p "$BUILD" "$ROOT/dist"
DATE="$(date +%Y-%m-%d)"

build() {
  local vol="$1" out="$2" title="$3" subtitle="$4"
  local md="$BUILD/$vol.md"
  : > "$md"
  for f in "$ROOT/$vol/README.md" "$ROOT/$vol"/[0-9][0-9]-*.md; do
    cat "$f" >> "$md"; printf '\n\n' >> "$md"
  done
  # Glossary at the end of every volume
  cat "$ROOT/GLOSSARY.md" >> "$md"
  # Metadata goes through a UTF-8 YAML file (command-line args can be mis-decoded without a UTF-8 locale).
  printf 'title: "%s"\nsubtitle: "%s"\ndate: "%s"\nlang: vi\n' "$title" "$subtitle" "$DATE" > "$BUILD/$vol.meta.yaml"
  pandoc "$md" -f gfm -t html5 --standalone --toc --toc-depth=1 \
    --metadata-file "$BUILD/$vol.meta.yaml" --css "$PDFDIR/style.css" --embed-resources \
    --highlight-style=tango -o "$BUILD/$vol.html"
  node "$PDFDIR/build-pdf.mjs" "$BUILD/$vol.html" "$ROOT/dist/$out" "$title"
}

build vol1-basics       csharp-tap1-co-ban.pdf     "C# / .NET — Tập 1: Cơ bản"    ".NET 10 LTS · C# 14 · cho người biết TypeScript/Java"
build vol2-intermediate csharp-tap2-trung-cap.pdf  "C# / .NET — Tập 2: Trung cấp" "Generics · LINQ · async · xUnit · DI"
build vol3-advanced     csharp-tap3-nang-cao.pdf   "C# / .NET — Tập 3: Nâng cao"  "Web API · EF Core · hiệu năng · Docker"

# Accent check: every PDF must contain these characters as real text.
fail=0
for pdf in "$ROOT"/dist/*.pdf; do
  txt="$(pdftotext -enc UTF-8 "$pdf" -)"
  pages="$(pdfinfo "$pdf" | awk '/^Pages:/{print $2}')"
  missing=""
  for ch in ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ; do
    grep -q "$ch" <<<"$txt" || missing+="$ch "
  done
  if [[ -n "$missing" ]]; then echo "ACCENT CHECK FAILED $(basename "$pdf"): missing $missing"; fail=1
  else echo "accent check OK: $(basename "$pdf") ($pages pages) contains ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ"; fi
done
exit $fail

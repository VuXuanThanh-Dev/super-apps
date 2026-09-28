#!/usr/bin/env bash
# Markdown (one or more files, in order) -> standalone HTML (pandoc) -> PDF (Playwright Chromium)
# -> accent/font check (check-pdf.py).
# Usage: build-pdf.sh -o dist/book.pdf [-t "Title"] [-c custom.css] chapter1.md chapter2.md ...
# Env: MERMAID_JS=/path/to/mermaid.min.js (only if the Markdown has ```mermaid blocks)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out=""; title=""; css="$here/../assets/book.css"
while getopts "o:t:c:" opt; do
  case $opt in o) out="$OPTARG";; t) title="$OPTARG";; c) css="$OPTARG";; *) exit 2;; esac
done
shift $((OPTIND - 1))
[[ -n "$out" && $# -gt 0 ]] || { echo "usage: build-pdf.sh -o out.pdf [-t title] [-c css] file.md ..." >&2; exit 2; }
mkdir -p "$(dirname "$out")"
html="${out%.pdf}.html"
meta=(); [[ -n "$title" ]] && meta=(--metadata "title=$title")
# --resource-path lets images next to each chapter resolve; --embed-resources makes one file.
pandoc "$@" -f markdown -t html5 --standalone --embed-resources --toc --toc-depth=2 \
  --metadata lang=vi "${meta[@]}" --css "$css" \
  --resource-path="$(printf '%s:' $(for f in "$@"; do dirname "$f"; done))." -o "$html"
NODE_PATH="${NODE_PATH:-}:$(npm root -g)" node "$here/render-pdf.cjs" "$html" "$out" "$title"
python3 "$here/check-pdf.py" "$out" --source "$@"

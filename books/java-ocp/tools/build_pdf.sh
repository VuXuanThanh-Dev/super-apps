#!/usr/bin/env bash
# Build the 3 PDFs into dist/ from the Markdown sources, then check Vietnamese accents with pdftotext.
# Needs: pandoc (tested 3.1.3), Node.js + global Playwright (tested 1.56.1) with Chromium, Noto fonts,
#        npm (first run installs Mermaid into tools/pdf/node_modules from tools/pdf/package-lock.json).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
OUT="$ROOT/build/pdf"
mkdir -p "$OUT" dist
if [ ! -f tools/pdf/node_modules/mermaid/dist/mermaid.min.js ]; then (cd tools/pdf && npm ci --no-audit --no-fund); fi
cat > "$OUT/after.html" <<AFTER
<script src="file://$ROOT/tools/pdf/node_modules/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({ startOnLoad: false, theme: 'neutral', fontFamily: 'Noto Sans' });</script>
AFTER
DATE=$(date -u +%Y-%m-%d)

cover() {  # cover <file.html> <title> <subtitle>  (inserted before the table of contents)
  cat > "$1" <<COVER
<div class="cover">
<h1 class="cover-title">$2</h1>
<p class="subtitle">$3</p>
<p class="meta">Oracle Certified Professional: Java SE 21 Developer (1Z0-830)<br>
Tất cả ví dụ và câu hỏi được kiểm chứng bằng OpenJDK 21.0.10 · Bản build $DATE</p>
<p class="meta">Không tài liệu nào bảo đảm điểm tuyệt đối — hãy dùng sách để hiểu Java, không để học thuộc.</p>
<p class="fontcheck">Kiểm tra font tiếng Việt: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ</p>
</div>
COVER
}

build() {  # build <name> <footer title> <body class> <toc yes|no> files...
  local name=$1 title=$2 klass=$3 toc=$4; shift 4
  local coverfile=$1; shift
  local tocflag=()
  [ "$toc" = yes ] && tocflag=(--toc --toc-depth=2)
  pandoc --from markdown-implicit_figures --to html5 --standalone "${tocflag[@]}" \
    --metadata pagetitle="$title" --highlight-style=pygments \
    --css "file://$ROOT/tools/pdf/style.css" --include-before-body "$coverfile" --include-after-body "$OUT/after.html" \
    --variable "header-includes=<style>body{}</style>" \
    -o "$OUT/$name.html" "$@"
  sed -i -e "s|<body>|<body class=\"$klass\">|" -e "s|<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"\" xml:lang=\"\">|<html lang=\"vi\">|" "$OUT/$name.html"
  NODE_PATH=$(npm root -g) node tools/pdf/render.cjs "$OUT/$name.html" "dist/$name.pdf" "$title"
}

cover "$OUT/cover-handbook.html" "Sổ tay ôn thi Java OCP 21" "Giải thích tiếng Việt · 10 chương · 124 ví dụ · 200 câu hỏi có lời giải"
cover "$OUT/cover-mock.html" "Đề thi thử Java OCP 21" "3 đề × 50 câu · 120 phút · đáp án và giải thích"
cover "$OUT/cover-cheat.html" "Cheat sheet Java OCP 21" "Mỗi chương một trang"

build java-ocp-handbook "Sổ tay ôn thi Java OCP 21 (1Z0-830)" handbook yes \
  "$OUT/cover-handbook.html" chapters/ch00-gioi-thieu.md DECISION.md \
  chapters/ch01-du-lieu.md chapters/ch02-luong-dieu-khien.md chapters/ch03-huong-doi-tuong.md \
  chapters/ch04-ngoai-le.md chapters/ch05-mang-va-collections.md chapters/ch06-lambda-va-stream.md \
  chapters/ch07-module-va-trien-khai.md chapters/ch08-dong-thoi.md chapters/ch09-io-va-nio2.md \
  chapters/ch10-ban-dia-hoa.md schedule/schedule.md GLOSSARY.md COVERAGE.md SOURCES.md

build java-ocp-mock-exams "Đề thi thử Java OCP 21 (1Z0-830)" mock no \
  "$OUT/cover-mock.html" mock/README.md mock/mock-exam-1.md mock/mock-exam-2.md mock/mock-exam-3.md \
  mock/mock-exam-1-answers.md mock/mock-exam-2-answers.md mock/mock-exam-3-answers.md

build java-ocp-cheatsheets "Cheat sheet Java OCP 21 (1Z0-830)" cheatsheets no \
  "$OUT/cover-cheat.html" cheatsheets/ch01.md cheatsheets/ch02.md cheatsheets/ch03.md cheatsheets/ch04.md \
  cheatsheets/ch05.md cheatsheets/ch06.md cheatsheets/ch07.md cheatsheets/ch08.md cheatsheets/ch09.md cheatsheets/ch10.md

echo "== Vietnamese accent check (pdftotext)"
status=0
for pdf in dist/java-ocp-handbook.pdf dist/java-ocp-mock-exams.pdf dist/java-ocp-cheatsheets.pdf; do
  txt=$(pdftotext -enc UTF-8 "$pdf" - 2>/dev/null)
  line="$pdf: pages=$(pdfinfo "$pdf" | awk '/^Pages/{print $2}')"
  for ch in ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ; do
    n=$(grep -o "$ch" <<<"$txt" | wc -l)
    line="$line $ch=$n"
    [ "$n" -gt 0 ] || status=1
  done
  echo "$line"
done
[ $status -eq 0 ] && echo "ACCENTS OK" || { echo "ACCENTS MISSING"; exit 1; }

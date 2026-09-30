#!/usr/bin/env bash
# Kiểm tra dấu tiếng Việt trong 3 PDF bằng pdftotext (poppler).
# - Mỗi ký tự trong danh sách phải xuất hiện (ở dạng dựng sẵn NFC).
# - Dòng kiểm tra trên trang bìa phải đọc lại đúng nguyên văn.
# - Không được có dấu rời (combining marks U+0300–U+036F) — dấu hiệu font/encoding hỏng.
set -euo pipefail
DIST="$(cd "$(dirname "$0")/../dist" && pwd)"
CHARS=(ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ)
PHRASE="Kiểm tra dấu tiếng Việt: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ — Đường ướt, trăng khuyết, Ưu tiên"
status=0
for pdf in "$DIST"/*.pdf; do
  txt="$(mktemp)"
  pdftotext -enc UTF-8 "$pdf" "$txt"
  line="$(basename "$pdf"):"
  for c in "${CHARS[@]}"; do
    n=$(grep -o "$c" "$txt" | wc -l)
    line+=" $c=$n"
    [ "$n" -gt 0 ] || status=1
  done
  if grep -qF "$PHRASE" "$txt"; then line+=" | câu kiểm tra: OK"; else line+=" | câu kiểm tra: THIẾU"; status=1; fi
  combining=$(python3 -c "import sys,re;print(len(re.findall('[̀-ͯ]', open(sys.argv[1],encoding='utf-8').read())))" "$txt")
  line+=" | dấu rời: $combining"
  [ "$combining" -eq 0 ] || status=1
  echo "$line"
  rm -f "$txt"
done
[ $status -eq 0 ] && echo "ACCENTS OK" || { echo "ACCENTS FAILED"; exit 1; }

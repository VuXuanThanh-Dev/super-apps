#!/usr/bin/env bash
# Run every helper script shipped inside .claude/skills on its sample input (positive + negative
# cases) and print real output. Exit 1 if any expectation fails.
# Needs: pandoc, node + playwright, poppler-utils, Noto fonts, JDK 21, dotnet 10, python3 + PyYAML.
# Optional: MERMAID_JS=/path/to/mermaid.min.js (else the Mermaid part of the PDF test is skipped).
set -uo pipefail
repo="$(cd "$(dirname "$0")/../../.." && pwd)"
S="$repo/.claude/skills"
tmp="$(mktemp -d)"
fail=0
expect() { # expect <wanted-exit> <label> <cmd...>
  local want="$1" label="$2"; shift 2
  echo "\$ $label"
  "$@"; local rc=$?
  if [[ "$rc" == "$want" ]]; then echo "→ exit $rc (expected $want) OK"; else echo "→ exit $rc (expected $want) FAIL"; fail=1; fi
  echo
}
echo "## vietnamese-pdf-builder"
if [[ -n "${MERMAID_JS:-}" ]]; then src="$S/vietnamese-pdf-builder/assets/accent-test.md"
else src="$tmp/accent-nomermaid.md"; sed '/^```mermaid/,/^```$/d' "$S/vietnamese-pdf-builder/assets/accent-test.md" > "$src"; fi
expect 0 "build-pdf.sh -o accent.pdf accent-test.md" "$S/vietnamese-pdf-builder/scripts/build-pdf.sh" -o "$tmp/accent.pdf" -t "Kiểm tra" "$src"
expect 0 "check-pdf.py accent.pdf --require-all" python3 "$S/vietnamese-pdf-builder/scripts/check-pdf.py" "$tmp/accent.pdf" --require-all
printf '# T\n\nBài tập.\n\n<details><summary>Lời giải</summary>\n\nĐáp án XYZ.\n\n</details>\n' > "$tmp/det.md"
"$S/vietnamese-pdf-builder/scripts/build-pdf.sh" -o "$tmp/det.pdf" "$tmp/det.md" > /dev/null 2>&1
expect 0 "details content printed (pdftotext | grep XYZ)" grep -q XYZ <(pdftotext "$tmp/det.pdf" -)
echo "## ocp-question-writer"
expect 0 "verify_questions.py sample-questions.yaml" python3 "$S/ocp-question-writer/scripts/verify_questions.py" "$S/ocp-question-writer/assets/sample-questions.yaml"
sed 's/expect: "small circle, square 3"/expect: "big circle, square 3"/' "$S/ocp-question-writer/assets/sample-questions.yaml" > "$tmp/bad.yaml"
expect 1 "verify_questions.py with a wrong expected output (must FAIL)" python3 "$S/ocp-question-writer/scripts/verify_questions.py" "$tmp/bad.yaml"
echo "## code-sample-runner"
cp "$S/code-sample-runner/assets/sample.md" "$tmp/sample.md"
expect 0 "run_samples.py sample.md" python3 "$S/code-sample-runner/scripts/run_samples.py" "$tmp/sample.md"
expect 0 "run_samples.py --check sample.md (fresh)" python3 "$S/code-sample-runner/scripts/run_samples.py" --check "$tmp/sample.md"
sed -i 's/Tổng = 6/Tổng = 7/' "$tmp/sample.md"
expect 1 "run_samples.py --check after editing an output by hand (must FAIL)" python3 "$S/code-sample-runner/scripts/run_samples.py" --check "$tmp/sample.md"
echo "## handbook-chapter-writer"
cat > "$tmp/ch.md" <<'MD'
# Chương 1 — Thử
## Mục tiêu
x
## Giải thích đơn giản
x
## Ví dụ
x
## Đi sâu
x
## Lỗi và bẫy thường gặp
x
## Tóm tắt
x
## Bài tập (có lời giải)
1. x
Lời giải: y
## Nguồn tham khảo
- https://github.com/dotnet/docs
MD
expect 0 "check_chapter.py good chapter" python3 "$S/handbook-chapter-writer/scripts/check_chapter.py" "$tmp/ch.md"
sed '/^## Đi sâu/,+1d' "$tmp/ch.md" > "$tmp/ch-bad.md"
expect 1 "check_chapter.py without 'Đi sâu' (must FAIL)" python3 "$S/handbook-chapter-writer/scripts/check_chapter.py" "$tmp/ch-bad.md"
echo "## vocabulary-extractor"
printf 'budget|n|money you plan to spend|We are over budget.\n' > "$tmp/known.txt"
expect 0 "extract_candidates.py sample-email.txt --known known.txt --top 8" python3 "$S/vocabulary-extractor/scripts/extract_candidates.py" "$S/vocabulary-extractor/assets/sample-email.txt" --known "$tmp/known.txt" --top 8
rm -rf "$tmp"
[[ $fail == 0 ]] && echo "ALL SCRIPT TESTS PASSED" || echo "SOME SCRIPT TESTS FAILED"
exit $fail

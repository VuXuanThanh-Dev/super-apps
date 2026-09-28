#!/usr/bin/env python3
"""Run the headless trigger test for every skill (4 in parallel) and print a summary.

One test per skill: a realistic prompt that does NOT name the skill, plus a small fixture from
docs/skills/test-fixtures/<skill>/. Evidence goes to docs/skills/test-results/<skill>.md.
Usage: run-all-tests.py [skill ...]   (default: all)
"""
import concurrent.futures as cf
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIX = HERE.parent / "test-fixtures"

TESTS = {
    "vietnamese-pdf-builder":
        "Build a print-ready PDF of chuong1.md into dist/chuong1.pdf and make sure the Vietnamese "
        "accents are correct in the PDF.",
    "ocp-question-writer":
        "Viết 2 câu hỏi trắc nghiệm luyện thi Java OCP 21 (tự viết, không lấy từ đề thật) về record và "
        "switch pattern matching. Lưu vào questions.yaml và chứng minh đáp án đúng.",
    "code-sample-runner":
        "The code examples in guide.md must show their real output. Please run them and put the real "
        "output under each example.",
    "handbook-chapter-writer":
        "Viết chương 5 cho sách C# (người mới học) về chủ đề `record`, bản ngắn gọn khoảng 1 trang, "
        "lưu vào chapters/ch05-record.md, có ví dụ chạy được trong examples/ch05/.",
    "angular-review-checklist":
        "Please review src/app/cart.component.ts in this Angular 22 project and list the problems "
        "with file:line and fixes. Do not edit files.",
    "csharp-review-checklist":
        "Check OrderService.cs for problems before I open the merge request. List issues with line "
        "numbers and how to fix them. Do not edit files.",
    "react-native-feature-checklist":
        "I want to add a 'Saved words' screen to this Expo app (list of saved words, stored offline). "
        "Give me the plan: which files to create, the steps, and what to check. Do not write the code yet.",
    "vocabulary-extractor":
        "Lấy từ vựng TOEIC hữu ích từ email.txt để thêm vào app học từ của tôi (định dạng "
        "word|pos|definition|example) và cho tôi bảng nghĩa tiếng Việt.",
    "webapp-testing":
        "Open index.html in a real headless browser, click the 'Save word' button and verify that the "
        "text 'Saved!' appears. Save a screenshot as saved.png.",
    "skill-creator":
        "Create a new Claude skill in .claude/skills/meeting-notes that turns raw meeting notes into "
        "a summary with decisions and action items. Keep it small; no benchmark runs needed.",
}


def run(skill):
    fixture = FIX / skill
    cmd = ["bash", str(HERE / "run-skill-test.sh"), skill, TESTS[skill]]
    if fixture.is_dir():
        cmd.append(str(fixture))
    p = subprocess.run(cmd, capture_output=True, text=True)
    return skill, p.returncode, p.stdout.strip().splitlines()[-3:]


def main():
    skills = sys.argv[1:] or list(TESTS)
    with cf.ThreadPoolExecutor(4) as ex:
        results = list(ex.map(run, skills))
    for skill, rc, tail in results:
        print(f"{'PASS' if rc == 0 else 'FAIL'} {skill}: {' | '.join(tail)}")
    return 0 if all(rc == 0 for _, rc, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())

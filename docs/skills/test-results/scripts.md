# Script tests — helper scripts inside skills

Lệnh: `MERMAID_JS=<mermaid.min.js> bash docs/skills/scripts/test-skill-scripts.sh` (chạy 2026-09-28T15:11Z; mermaid 12.0.0).

Output thật:

```text
## vietnamese-pdf-builder
$ build-pdf.sh -o accent.pdf accent-test.md
[WARNING] Could not load translations for vi
  translations/vi.yaml: Aeson exception:
  Error in $: Invalid Term name "Also"
[WARNING] The term Abstract has no translation defined.
mermaid: 1/1 diagram(s) rendered to SVG
pdf: <tmp>/accent.pdf
char  in_source  in_pdf
ắ             3       3  ok
ằ             2       2  ok
ẳ             2       2  ok
ẵ             2       2  ok
ặ             3       3  ok
ơ             3       4  ok
ư             7       8  ok
đ             5       5  ok
Ư             2       2  ok
Đ             3       3  ok
fonts: AAAAAA+NotoSans-Bold, BAAAAA+NotoSans-Regular, CAAAAA+NotoSerif-Regular, DAAAAA+NotoSansMono-Regular
Pages:           2
RESULT: PASS
→ exit 0 (expected 0) OK

$ check-pdf.py accent.pdf --require-all
char  in_source  in_pdf
ắ             0       3  ok
ằ             0       2  ok
ẳ             0       2  ok
ẵ             0       2  ok
ặ             0       3  ok
ơ             0       4  ok
ư             0       8  ok
đ             0       5  ok
Ư             0       2  ok
Đ             0       3  ok
fonts: AAAAAA+NotoSans-Bold, BAAAAA+NotoSans-Regular, CAAAAA+NotoSerif-Regular, DAAAAA+NotoSansMono-Regular
Pages:           2
RESULT: PASS
→ exit 0 (expected 0) OK

$ details content printed (pdftotext | grep XYZ)
→ exit 0 (expected 0) OK

## ocp-question-writer
$ verify_questions.py sample-questions.yaml
PASS S-01: output 'small circle, square 3' confirmed
PASS S-02: compile error on lines [7] confirmed

2/2 questions verified with javac 21.0.10 --release 21
→ exit 0 (expected 0) OK

$ verify_questions.py with a wrong expected output (must FAIL)
FAIL S-01
   stdout mismatch
   --- got ---
   small circle, square 3
   --- expected ---
   big circle, square 3
   option B text != expected output
   options ['A'] have the same text as the answer
PASS S-02: compile error on lines [7] confirmed

1/2 questions verified with javac 21.0.10 --release 21
→ exit 1 (expected 1) OK

## code-sample-runner
$ run_samples.py sample.md
<tmp>/sample.md: ok=4 failed=0 not_run=0 updated=4
→ exit 0 (expected 0) OK

$ run_samples.py --check sample.md (fresh)
<tmp>/sample.md: ok=4 failed=0 not_run=0 outdated=0
→ exit 0 (expected 0) OK

$ run_samples.py --check after editing an output by hand (must FAIL)
<tmp>/sample.md: ok=4 failed=0 not_run=0 outdated=1
→ exit 1 (expected 1) OK

## handbook-chapter-writer
$ check_chapter.py good chapter
OK   <tmp>/ch.md
→ exit 0 (expected 0) OK

$ check_chapter.py without 'Đi sâu' (must FAIL)
FAIL <tmp>/ch-bad.md
   - missing or out-of-order section '## Đi sâu'
→ exit 1 (expected 1) OK

## vocabulary-extractor
$ extract_candidates.py sample-email.txt --known known.txt --top 8
{
 "lemmas": [
  {
   "lemma": "renovation",
   "count": 3,
   "forms": [
    "renovation"
   ],
   "known": false,
   "context": "Dear Ms. Tran, Thank you for submitting your proposal for the office renovation."
  },
  {
   "lemma": "schedule",
   "count": 3,
   "forms": [
    "schedule",
    "scheduled"
   ],
   "known": false,
   "context": "Our facilities manager reviewed the proposal and scheduled a site visit for next Tuesday."
  },
  {
   "lemma": "proposal",
   "count": 2,
   "forms": [
    "proposal"
   ],
   "known": false,
   "context": "Dear Ms. Tran, Thank you for submitting your proposal for the office renovation."
  },
  {
   "lemma": "facility",
   "count": 2,
   "forms": [
    "facilities"
   ],
   "known": false,
   "context": "Our facilities manager reviewed the proposal and scheduled a site visit for next Tuesday."
  },
  {
   "lemma": "manager",
   "count": 2,
   "forms": [
    "manager"
   ],
   "known": false,
   "context": "Our facilities manager reviewed the proposal and scheduled a site visit for next Tuesday."
  },
  {
   "lemma": "estimate",
   "count": 2,
   "forms": [
    "estimate"
   ],
   "known": false,
   "context": "Before we sign the contract, we need a detailed estimate for the flooring and the lighting."
  },
  {
   "lemma": "tran",
   "count": 1,
   "forms": [
    "tran"
   ],
   "known": false,
   "context": "Dear Ms. Tran, Thank you for submitting your proposal for the office renovation."
  },
  {
   "lemma": "submit",
   "count": 1,
   "forms": [
    "submitting"
   ],
   "known": false,
   "context": "Dear Ms. Tran, Thank you for submitting your proposal for the office renovation."
  }
 ],
 "bigrams": [
  {
   "phrase": "facility manager",
   "count": 2
  }
 ],
 "stats": {
  "lemmatizer": "simplemma",
  "tokens": 110,
  "distinct_lemmas": 44,
  "known_skipped": 1,
  "returned": 8
 }
}
→ exit 0 (expected 0) OK

ALL SCRIPT TESTS PASSED
exit=0
```

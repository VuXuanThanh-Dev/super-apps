#!/usr/bin/env bash
# Build the FULL (book-derived) dataset for this app. Output goes ONLY to private-data/ (git-ignored).
#
# Reuses Task 5's pipeline instead of redoing it:
#   1. apps/toeic/tools/extract_books.py + build_dataset.py  -> apps/toeic/private-data/dataset.json
#      (only the two private steps; they write only to apps/toeic/private-data/, which is git-ignored.
#       We do NOT run apps/toeic/tools/build_data.sh because it also rewrites committed files of Task 5.)
#   2. copy it to private-data/source/dataset.json
#   3. merge your own words (private-data/my-words/*.txt) and import into SQLite: private-data/toeic.db
#      with a lossless check (SQLite -> JSON must equal the input).
# Needs: python3, `pip install -r ../toeic/tools/requirements.txt`, and WordNet data:
#   python3 -c "import nltk; nltk.download('wordnet')"
# Set SKIP_TASK5_BUILD=1 to reuse an existing apps/toeic/private-data/dataset.json.
set -euo pipefail
cd "$(dirname "$0")/.."
RN=../toeic
if [ "${SKIP_TASK5_BUILD:-0}" != "1" ]; then
  (cd "$RN" && python3 tools/extract_books.py && python3 tools/build_dataset.py)
fi
[ -f "$RN/private-data/dataset.json" ] || { echo "missing $RN/private-data/dataset.json"; exit 1; }
mkdir -p private-data/source
cp "$RN/private-data/dataset.json" private-data/source/dataset.json
python3 tools/import_words.py --rebuild

#!/usr/bin/env bash
# Rebuild all data. Book-derived output goes ONLY to private-data/ (git-ignored).
# Needs: python3 + `pip install -r tools/requirements.txt` + WordNet data:
#   python3 -c "import nltk; nltk.download('wordnet')"
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/passages_to_json.py          # my passages (txt -> json), public
python3 tools/build_sample.py              # public sample dataset + generic glosses
python3 tools/build_irregular.py           # WordNet irregular forms -> src/features/lookup/irregular.json
python3 tools/extract_books.py             # PDFs -> private-data/raw + extracted
python3 tools/build_dataset.py             # -> private-data/dataset.json + toeic.db

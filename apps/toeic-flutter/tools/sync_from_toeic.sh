#!/usr/bin/env bash
# Copy the PUBLIC (non-book) content of Task 5 (apps/toeic) into this app, and rebuild the sample DB.
# All files below were written for Task 5 (own writing) or come from open-licensed data
# (WordNet 3.0 / CMUdict, see apps/toeic/tools/LICENSES.md). Credit: apps/toeic/.
# Usage (from apps/toeic-flutter/): bash tools/sync_from_toeic.sh
set -euo pipefail
cd "$(dirname "$0")/.."
RN=../toeic
cp "$RN/src/content/dialogs.json"          assets/content/dialogs.json         # roleplay dialogs (own writing)
cp "$RN/src/content/function-words.json"   assets/content/function-words.json  # common words (own writing)
cp "$RN/src/data/generic-glosses.json"     assets/content/generic-glosses.json # WordNet 3.0 glosses (public)
cp "$RN/src/features/lookup/irregular.json" assets/content/irregular.json      # WordNet exception lists
cp "$RN/src/data/sample/dataset.json"      test/fixtures/sample_dataset.json   # public sample (own writing)
python3 tools/import_dataset.py test/fixtures/sample_dataset.json assets/data/sample.db
echo "synced from $RN"

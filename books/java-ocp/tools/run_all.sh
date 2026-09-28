#!/usr/bin/env bash
# Build and run ALL examples, check ALL questions, regenerate COVERAGE.md, check links.
# Usage: bash tools/run_all.sh        (from books/java-ocp or anywhere)
# Needs: JDK 21 (tested with OpenJDK 21.0.10), Python 3.11 + PyYAML, curl.
set -euo pipefail
cd "$(dirname "$0")/.."
unset JAVA_TOOL_OPTIONS || true
java -version 2>&1 | head -1
python3 tools/book.py examples
python3 tools/book.py questions
python3 tools/book.py coverage
python3 tools/check_links.py | tail -3

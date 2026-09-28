#!/usr/bin/env bash
set -e
OUT="$(mktemp -d)"
echo '$ tsc --version'
tsc --version
echo '$ tsc --strict --target es2022 --module nodenext --outDir out compare.ts && node out/compare.js'
tsc --strict --target es2022 --module nodenext --outDir "$OUT" compare.ts
node "$OUT/compare.js"
rm -rf "$OUT"

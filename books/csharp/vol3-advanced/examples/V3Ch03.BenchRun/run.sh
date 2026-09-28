#!/usr/bin/env bash
# Runs the BenchmarkDotNet project with a SHORT job (3 iterations -> less precise, but ~1 minute).
# Only the "Summary" blocks of the BenchmarkDotNet log are kept.
set -euo pipefail
cd ../V3Ch03.Bench
echo '$ dotnet run -c Release -- --job short --filter "*"'
log="$(mktemp)"
dotnet run -c Release -- --job short --filter "*" > "$log" 2>&1
awk '/^\/\/ \* Summary \*/{f=1;print "// * Summary *";next} /^\/\/ \* Legends \*/{f=0} f' "$log" | grep -v '^$'
grep '^Global total time' "$log"
[[ -f /proc/loadavg ]] && echo "Load average khi chạy xong (1/5/15 phút): $(cut -d" " -f1-3 /proc/loadavg)"
rm -f "$log"

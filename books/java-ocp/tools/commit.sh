#!/usr/bin/env bash
# Helper used during writing: commit books/java-ocp and push (retries on network errors).
set -e
cd "$(dirname "$0")/../../.."
git add books/java-ocp
git commit -q -m "$1

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_0126YtJGrqxgqaLLoF9qbauB"
for s in 2 4 8 16; do git push -q -u origin task-2-java-ocp 2>/dev/null && break || sleep $s; done
git log --oneline -1

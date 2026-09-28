#!/usr/bin/env bash
# Build + run the final project's Docker image and call it (see final-project/scripts/docker-smoke.sh).
# Behind a TLS-inspecting proxy: export CA_BUNDLE=/path/to/ca-bundle.crt before running.
set -euo pipefail
../../final-project/scripts/docker-smoke.sh

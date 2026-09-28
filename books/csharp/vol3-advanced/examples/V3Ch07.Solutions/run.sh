#!/usr/bin/env bash
# Exercise: run the API with docker compose and check that data survives a container restart.
# Uses the image taskboard-api:dev built by V3Ch07.Docker (so no second build is needed here).
set -euo pipefail
cd ../../final-project
export COMPOSE_PROJECT_NAME=taskboard-ex
docker compose down -v >/dev/null 2>&1 || true
trap 'docker compose down -v >/dev/null 2>&1 || true' EXIT
echo '$ docker compose up -d --no-build'
docker compose up -d --no-build 2>&1 | grep -v -i "warn" | sed 's/^ *//' | grep -E "Created|Started|Running" || true
wait_up() { for i in $(seq 1 30); do curl -fsS localhost:8080/health >/dev/null 2>&1 && return; sleep 1; done; }
wait_up
echo '$ curl -X POST localhost:8080/api/tasks ...'
curl -sS -o /dev/null -w 'HTTP %{http_code}\n' -X POST localhost:8080/api/tasks -H 'Content-Type: application/json' -d '{"title":"Dữ liệu phải còn sau restart"}'
echo '$ docker compose restart api'
docker compose restart api >/dev/null 2>&1
wait_up
echo '$ curl localhost:8080/api/tasks'
curl -sS localhost:8080/api/tasks | python3 -c 'import json,sys; d=json.load(sys.stdin); print("totalCount =", d["totalCount"], "| title =", d["items"][0]["title"])'

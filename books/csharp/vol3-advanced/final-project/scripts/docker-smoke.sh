#!/usr/bin/env bash
# Build the Docker image, run it, call a few endpoints, then clean up.
# Behind a TLS-inspecting proxy, set CA_BUNDLE=/path/to/ca-bundle.crt (and HTTPS_PROXY).
set -euo pipefail
cd "$(dirname "$0")/.."
IMAGE=taskboard-api:dev
NAME=taskboard-smoke
PORT=18080

build_args=()
if [[ -n "${CA_BUNDLE:-}" ]]; then
  build_args+=(--network host --secret "id=ca_bundle,src=$CA_BUNDLE")
  [[ -n "${HTTPS_PROXY:-}" ]] && build_args+=(--build-arg "HTTPS_PROXY=$HTTPS_PROXY" --build-arg "HTTP_PROXY=$HTTPS_PROXY")
fi

echo "\$ docker build -t $IMAGE ."
docker build -q "${build_args[@]}" -t "$IMAGE" . >/dev/null
docker image ls "$IMAGE" --format 'image {{.Repository}}:{{.Tag}} size={{.Size}}'

docker rm -f "$NAME" >/dev/null 2>&1 || true
echo "\$ docker run -d -p $PORT:8080 --name $NAME $IMAGE"
docker run -d -p "$PORT:8080" --name "$NAME" "$IMAGE" >/dev/null
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

for i in $(seq 1 30); do
  curl -fsS "http://localhost:$PORT/health" >/dev/null 2>&1 && break
  sleep 1
done

call() { echo "\$ curl $*"; curl -sS -w '\n-> HTTP %{http_code}\n' "$@"; }
call "http://localhost:$PORT/health"
call -X POST "http://localhost:$PORT/api/tasks" -H 'Content-Type: application/json' \
  -d '{"title":"Triển khai bằng Docker","priority":"High","dueDate":"2030-01-31"}'
call -X PATCH "http://localhost:$PORT/api/tasks/1/status" -H 'Content-Type: application/json' -d '{"status":"Done"}'
call "http://localhost:$PORT/api/tasks?status=Todo"
echo "\$ docker exec $NAME whoami"
docker exec "$NAME" whoami
echo "\$ docker logs $NAME (last 4 lines)"
docker logs "$NAME" 2>&1 | tail -4

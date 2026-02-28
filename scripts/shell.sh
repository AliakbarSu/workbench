#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKER_CONTAINER_NAME="workbench"
DOCKER_IMAGE="workbench"
DOCKERFILE="${SCRIPT_DIR}/../Dockerfile"
MOUNTS_FILE="${SCRIPT_DIR}/../mounts.yaml"

if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
  echo "Image '${DOCKER_IMAGE}' not found, building..."
  docker build -t "$DOCKER_IMAGE" -f "$DOCKERFILE" "${SCRIPT_DIR}/.."
fi

# Build mount flags from mounts.yaml paths list
mount_args=()
while IFS= read -r path; do
  name=$(basename "$path")
  mount_args+=(-v "${path}:/projects/${name}")
done < <(grep -E '^\s*-\s+' "$MOUNTS_FILE" | sed 's/^[[:space:]]*-[[:space:]]*//')

if docker ps -q -f "name=^${DOCKER_CONTAINER_NAME}$" | grep -q .; then
  echo "Attaching to running container..."
elif docker ps -aq -f "name=^${DOCKER_CONTAINER_NAME}$" | grep -q .; then
  echo "Restarting stopped container '${DOCKER_CONTAINER_NAME}'..."
  docker start "$DOCKER_CONTAINER_NAME"
else
  echo "Starting new container '${DOCKER_CONTAINER_NAME}'..."
  docker run -d --name "$DOCKER_CONTAINER_NAME" \
    "${mount_args[@]}" \
    "$DOCKER_IMAGE" sleep infinity
fi

docker cp "${SCRIPT_DIR}/../claude-user-setting/." "$DOCKER_CONTAINER_NAME:/home/node/.claude/"

docker exec -it -w "/projects" "$DOCKER_CONTAINER_NAME" /bin/zsh

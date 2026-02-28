#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKER_CONTAINER_NAME="workbench"
DOCKER_IMAGE="workbench"
DOCKERFILE="${SCRIPT_DIR}/../Dockerfile"
MOUNTS_FILE="${SCRIPT_DIR}/../config/mounts.yaml"

if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
  echo "Image '${DOCKER_IMAGE}' not found, building..."
  docker build -t "$DOCKER_IMAGE" -f "$DOCKERFILE" "${SCRIPT_DIR}/.."
fi

# Build mount flags from mounts.yaml paths list.
# Each path is mounted at the same absolute path inside the container so that
# git worktree references (which store absolute host paths) resolve correctly.
mount_args=()
first_path=""
while IFS= read -r path; do
  [[ -z "$first_path" ]] && first_path="$path"
  mount_args+=(-v "${path}:${path}")
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
    -v "${HOME}/.ssh/id_ed25519:/home/node/.ssh/id_ed25519:ro" \
    -v "${HOME}/.ssh/id_ed25519.pub:/home/node/.ssh/id_ed25519.pub:ro" \
    "$DOCKER_IMAGE" sleep infinity
fi

docker cp "${SCRIPT_DIR}/../terminal-config/.zshrc" "$DOCKER_CONTAINER_NAME:/home/node/.zshrc"

docker exec -it -w "${first_path:-/}" "$DOCKER_CONTAINER_NAME" /bin/zsh

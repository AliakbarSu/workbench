#!/bin/sh

set -eu

WORKTREE_NAME=$(basename "$PWD")
PROJECTS_DIR=$(dirname "$PWD")
DOCKER_CONTAINER_NAME="survesy-dev"
DOCKER_IMAGE="survesy-dev"
DOCKERFILE="$(dirname "$0")/Dockerfile.dev"

if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
  echo "Image '${DOCKER_IMAGE}' not found, building..."
  docker build -t "$DOCKER_IMAGE" -f "$DOCKERFILE" "$(dirname "$0")"
fi

if docker ps -q -f "name=^${DOCKER_CONTAINER_NAME}$" | grep -q .; then
  echo "Attaching to running container in /projects/${WORKTREE_NAME}..."
elif docker ps -aq -f "name=^${DOCKER_CONTAINER_NAME}$" | grep -q .; then
  echo "Restarting stopped container '${DOCKER_CONTAINER_NAME}'..."
  docker start "$DOCKER_CONTAINER_NAME"
else
  echo "Starting new container '${DOCKER_CONTAINER_NAME}'..."
  docker run -d --name "$DOCKER_CONTAINER_NAME" \
    -v "${PROJECTS_DIR}:/projects" \
    "$DOCKER_IMAGE" sleep infinity
fi

docker exec -it -w "/projects/${WORKTREE_NAME}" "$DOCKER_CONTAINER_NAME" /bin/zsh

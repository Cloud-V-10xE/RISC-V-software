#!/bin/bash
set -e

# Set runner name
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"

if [[ ! -f ".runner" ]]; then
  if [[ -z "$GITHUB_REPO" || -z "$RUNNER_TOKEN" ]]; then
    echo "Missing GITHUB_REPO or RUNNER_TOKEN"
    exit 1
  fi

  CONFIG_CMD=(
    ./config.sh
    --url "${GITHUB_REPO}"
    --token "${RUNNER_TOKEN}"
    --name "${RUNNER_NAME}"
    --unattended
    --replace
  )

  # Optional labels, so this variant matches the docker-in-docker one.
  if [[ -n "${RUNNER_LABELS}" ]]; then
    echo "Configuring runner with labels: ${RUNNER_LABELS}"
    CONFIG_CMD+=(--labels "${RUNNER_LABELS}")
  fi

  "${CONFIG_CMD[@]}"
fi

./run.sh

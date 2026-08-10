#!/bin/bash
set -e

echo "=== GitHub Actions Runner Startup ==="

# --- DYNAMIC DOCKER GID MATCHING ---
# The bind-mounted socket's GID differs per host, so the container's docker
# group has to be re-numbered to match it before runneruser can use docker.
DOCKER_SOCKET=/var/run/docker.sock

if [ -S "${DOCKER_SOCKET}" ]; then
    echo "Docker socket detected: ${DOCKER_SOCKET}"

    DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
    echo "Docker socket GID: ${DOCKER_GID}"

    EXISTING_GROUP=$(getent group ${DOCKER_GID} | cut -d: -f1 || echo "")

    if [ -n "${EXISTING_GROUP}" ] && [ "${EXISTING_GROUP}" != "docker" ]; then
        echo "Group ${EXISTING_GROUP} already exists with GID ${DOCKER_GID}"
        echo "Removing it to create docker group..."
        groupdel ${EXISTING_GROUP} || true
    fi

    if getent group docker > /dev/null 2>&1; then
        echo "Docker group exists, modifying GID to ${DOCKER_GID}..."
        groupmod -g ${DOCKER_GID} docker
    else
        echo "Creating docker group with GID ${DOCKER_GID}..."
        groupadd -g ${DOCKER_GID} docker
    fi

    echo "Adding runneruser to docker group..."
    usermod -aG docker runneruser

    echo "runneruser groups: $(groups runneruser)"

    echo "Testing Docker access..."
    if su - runneruser -c "docker version" > /dev/null 2>&1; then
        echo "✓ Docker access confirmed!"
    else
        echo "⚠ Warning: Docker access test failed, but continuing..."
    fi
else
    echo "Warning: Docker socket not found at ${DOCKER_SOCKET}"
    echo "Docker commands will not work in this container"
fi

# --- GITHUB RUNNER CONFIGURATION ---
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"

echo "Configuring runner as user: runneruser"
cd /home/runner

# Drop to runneruser for registration and run. Explicitly bash, not sh —
# the script below uses [[ ]].
exec su - runneruser -c "/bin/bash <<'EOFSCRIPT'
    cd /home/runner

    if [[ ! -f .runner ]]; then
        if [[ -z '${GITHUB_REPO}' || -z '${RUNNER_TOKEN}' ]]; then
            echo 'Missing GITHUB_REPO or RUNNER_TOKEN'
            exit 1
        fi

        echo 'Registering runner: ${RUNNER_NAME}'

        CONFIG_CMD=(
            ./config.sh
            --url '${GITHUB_REPO}'
            --token '${RUNNER_TOKEN}'
            --name '${RUNNER_NAME}'
            --unattended
            --replace
        )

        if [[ -n '${RUNNER_LABELS}' ]]; then
            echo 'Configuring runner with labels: ${RUNNER_LABELS}'
            CONFIG_CMD+=(--labels '${RUNNER_LABELS}')
        fi

        \"\${CONFIG_CMD[@]}\"
    fi

    echo 'Starting GitHub Actions runner...'
    ./run.sh
EOFSCRIPT
"

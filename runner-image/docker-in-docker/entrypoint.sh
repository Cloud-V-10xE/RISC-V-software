#!/usr/bin/env bash
# Root-stage entrypoint for the Docker-capable runner image.
#
# Prepares Docker access, then permanently drops to runneruser. Nothing in this
# file runs after the drop — the runner never regains root.
#
#   DOCKER_MODE=auto   socket bind-mounted -> host; otherwise dind if the
#                      container has the capabilities for it; otherwise none
#   DOCKER_MODE=host   docker-out-of-docker: jobs drive the HOST daemon
#   DOCKER_MODE=dind   true docker-in-docker: a private dockerd in this container
#   DOCKER_MODE=none   no Docker access at all
set -Eeuo pipefail

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_MODE="${DOCKER_MODE:-auto}"
DOCKERD_PID=""

log()  { printf '[entrypoint] %s\n' "$*"; }
warn() { printf '[entrypoint] WARNING: %s\n' "$*" >&2; }
die()  { printf '[entrypoint] ERROR: %s\n' "$*" >&2; exit 1; }

[[ "$(id -u)" -eq 0 ]] || die "this entrypoint must start as root (it drops privileges itself)"

# --- dind preflight ---------------------------------------------------------
# Capabilities alone are not enough, and testing only for them produces the
# worst outcome: dockerd comes up, then every `docker build` dies deep inside a
# job. All four of these are required, and in practice only --privileged grants
# the full set:
#
#   CAP_SYS_ADMIN            mounting the storage driver
#   CAP_NET_ADMIN            creating docker0 and its iptables rules
#   writable /proc/sys       "Unable to enable local routing for hairpin mode"
#   writable /sys/fs/cgroup  "unable to apply cgroup configuration: mkdir
#                             /sys/fs/cgroup/docker: read-only file system"
has_cap() {
    local bit="$1" eff
    eff="$(awk '/^CapEff:/ {print $2}' /proc/self/status)"
    (( (0x${eff} >> bit) & 1 ))
}
CAP_NET_ADMIN=12
CAP_SYS_ADMIN=21

DIND_BLOCKERS=""
check_dind_prereqs() {
    DIND_BLOCKERS=""
    has_cap "${CAP_SYS_ADMIN}" \
        || DIND_BLOCKERS+=$'\n  - CAP_SYS_ADMIN is not held'
    has_cap "${CAP_NET_ADMIN}" \
        || DIND_BLOCKERS+=$'\n  - CAP_NET_ADMIN is not held'
    [[ -w /proc/sys/net/ipv4/ip_forward ]] \
        || DIND_BLOCKERS+=$'\n  - /proc/sys is read-only, so dockerd cannot set up its bridge'
    [[ -w /sys/fs/cgroup ]] \
        || DIND_BLOCKERS+=$'\n  - /sys/fs/cgroup is read-only, so runc cannot create cgroups for containers'
    [[ -z "${DIND_BLOCKERS}" ]]
}

# --- mode resolution --------------------------------------------------------
resolve_mode() {
    case "${DOCKER_MODE}" in
        host|dind|none) return 0 ;;
        auto) ;;
        *) die "DOCKER_MODE must be one of: auto, host, dind, none (got '${DOCKER_MODE}')" ;;
    esac

    if [[ -S "${DOCKER_SOCKET}" ]]; then
        DOCKER_MODE=host
    elif check_dind_prereqs; then
        DOCKER_MODE=dind
    else
        DOCKER_MODE=none
        warn "dind is not possible in this container:${DIND_BLOCKERS}"
    fi
    log "DOCKER_MODE=auto resolved to '${DOCKER_MODE}'"
}

# --- docker-out-of-docker ---------------------------------------------------
setup_host_docker() {
    [[ -S "${DOCKER_SOCKET}" ]] \
        || die "DOCKER_MODE=host but ${DOCKER_SOCKET} is not bind-mounted"

    local sock_gid existing
    sock_gid="$(stat -c '%g' "${DOCKER_SOCKET}")"
    log "host docker socket detected (gid ${sock_gid})"

    existing="$(getent group "${sock_gid}" | cut -d: -f1 || true)"
    if [[ -n "${existing}" ]]; then
        # Join whatever group already owns that GID rather than deleting it.
        # The old code ran groupdel here, which happily removed a system group
        # whose GID happened to collide and orphaned every file it owned.
        log "gid ${sock_gid} belongs to group '${existing}' — adding runneruser to it"
        usermod -aG "${existing}" runneruser
    else
        log "renumbering the docker group to ${sock_gid}"
        groupmod -g "${sock_gid}" docker
        usermod -aG docker runneruser
    fi

    if setpriv --reuid=runneruser --regid=runneruser --init-groups \
            -- docker version >/dev/null 2>&1; then
        log "docker access confirmed"
    else
        warn "runneruser cannot talk to the host daemon — docker steps will fail"
    fi

    cat >&2 <<'EOF'
[entrypoint] SECURITY: host mode grants every workflow that lands on this
[entrypoint] runner root-equivalent control of the Docker host. Use it only for
[entrypoint] trusted repositories; use DOCKER_MODE=dind for anything that runs
[entrypoint] fork pull requests.
EOF
}

# --- true docker-in-docker --------------------------------------------------
setup_dind() {
    check_dind_prereqs \
        || die "DOCKER_MODE=dind, but this container cannot host a daemon:${DIND_BLOCKERS}"$'\n\n'"  Run the container with --privileged."

    if [[ -S "${DOCKER_SOCKET}" ]]; then
        warn "a docker socket is bind-mounted but dind was requested — the inner daemon will shadow it"
    fi

    # overlay2 cannot stack on an overlay2 upper dir. Without a real volume here
    # dockerd silently falls back to vfs, which copies every layer and turns a
    # two-minute build into an hour on SG2042.
    if ! mountpoint -q /var/lib/docker; then
        warn "/var/lib/docker is not a mount — mount a volume there or dockerd falls back to vfs"
    fi

    local extra_args=()
    if [[ -n "${DOCKERD_EXTRA_ARGS:-}" ]]; then
        read -r -a extra_args <<< "${DOCKERD_EXTRA_ARGS}"
    fi

    log "starting the inner dockerd"
    dockerd \
        --host="unix://${DOCKER_SOCKET}" \
        --group=docker \
        --data-root=/var/lib/docker \
        --storage-driver="${DOCKER_STORAGE_DRIVER:-overlay2}" \
        --userland-proxy=false \
        "${extra_args[@]}" \
        >/var/log/dockerd.log 2>&1 &
    DOCKERD_PID=$!

    local timeout="${DOCKER_START_TIMEOUT:-90}" i
    for (( i = 0; i < timeout; i++ )); do
        if docker version >/dev/null 2>&1; then
            log "inner dockerd is up after ${i}s"
            return 0
        fi
        kill -0 "${DOCKERD_PID}" 2>/dev/null || { tail -n 40 /var/log/dockerd.log >&2; die "dockerd exited during startup"; }
        sleep 1
    done

    tail -n 40 /var/log/dockerd.log >&2
    die "dockerd did not become ready within ${timeout}s"
}

stop_dockerd() {
    [[ -n "${DOCKERD_PID}" ]] || return 0
    kill -0 "${DOCKERD_PID}" 2>/dev/null || return 0
    log "stopping the inner dockerd"
    kill -TERM "${DOCKERD_PID}" 2>/dev/null || true
    wait "${DOCKERD_PID}" 2>/dev/null || true
}

# --- main -------------------------------------------------------------------
resolve_mode

case "${DOCKER_MODE}" in
    host) setup_host_docker ;;
    dind) setup_dind ;;
    none) warn "no Docker access configured — docker steps in workflows will fail" ;;
esac

# Drop privileges for good. setpriv is used rather than `su -c "<string>"`
# because the old form interpolated ${RUNNER_TOKEN} into a command line, where
# it was readable in `ps` for the lifetime of the container.
runner_argv=(
    setpriv
    --reuid=runneruser
    --regid=runneruser
    --init-groups
    --inh-caps=-all
)
# Blocks setuid binaries outright, sudo included — so it stays opt-in.
if [[ "${RUNNER_NO_NEW_PRIVS:-false}" == "true" ]]; then
    runner_argv+=( --no-new-privs )
fi
runner_argv+=( -- /usr/local/bin/runner.sh )

if [[ -n "${DOCKERD_PID}" ]]; then
    # dockerd is a child of this shell, so we have to stay alive to shut it
    # down cleanly. exec would orphan it mid-build.
    HOME=/home/runner USER=runneruser LOGNAME=runneruser "${runner_argv[@]}" &
    RUNNER_PID=$!

    trap 'kill -TERM "${RUNNER_PID}" 2>/dev/null || true' TERM INT

    # A trap makes `wait` return >128 without the child having exited, so keep
    # waiting until it is genuinely gone — otherwise dockerd is torn down while
    # the runner is still draining its job.
    status=0
    while :; do
        # `rc=$?` after a closed `if` reads the if-statement's own status, not
        # the condition's — capture it on the || instead.
        rc=0
        wait "${RUNNER_PID}" || rc=$?
        if (( rc <= 128 )) || ! kill -0 "${RUNNER_PID}" 2>/dev/null; then
            status="${rc}"
            break
        fi
    done

    stop_dockerd
    exit "${status}"
else
    exec env HOME=/home/runner USER=runneruser LOGNAME=runneruser "${runner_argv[@]}"
fi

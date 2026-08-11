#!/usr/bin/env bash
# Registers (if needed) and runs the Actions runner.
#
# This script is ALWAYS executed as runneruser, never as root. The unprivileged
# image uses it as its entrypoint directly; the Docker-capable image starts as
# root to set up the daemon and then drops into this via setpriv.
#
# Shared by both variants deliberately — registration flags are exactly the kind
# of thing that silently drifts when two copies exist.
set -Eeuo pipefail

log() { printf '[runner] %s\n' "$*"; }

cd /home/runner

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"

# _FILE indirection, so secrets can come from a mounted file instead of an env
# var. An env var is visible in `docker inspect` and in /proc/<pid>/environ for
# anything running in the container.
if [[ -n "${RUNNER_TOKEN_FILE:-}" ]]; then
    [[ -r "${RUNNER_TOKEN_FILE}" ]] \
        || { echo "RUNNER_TOKEN_FILE is set but ${RUNNER_TOKEN_FILE} is not readable" >&2; exit 1; }
    RUNNER_TOKEN="$(< "${RUNNER_TOKEN_FILE}")"
fi
if [[ -n "${GITHUB_PAT_FILE:-}" ]]; then
    [[ -r "${GITHUB_PAT_FILE}" ]] \
        || { echo "GITHUB_PAT_FILE is set but ${GITHUB_PAT_FILE} is not readable" >&2; exit 1; }
    GITHUB_PAT="$(< "${GITHUB_PAT_FILE}")"
fi

# A registration token is single-use and expires in about an hour. That makes a
# static RUNNER_TOKEN incompatible with two things at once: --restart always and
# RUNNER_EPHEMERAL, because an ephemeral runner deletes its own registration
# after one job and the container then restarts into a re-registration that the
# spent token cannot satisfy — GitHub answers 404 and the container crash-loops.
#
# Given a PAT we mint a fresh token on every start instead, which is what makes
# ephemeral mode viable at all.
mint_registration_token() {
    local api="${GITHUB_API_URL:-https://api.github.com}"
    local path="${GITHUB_REPO%/}"
    path="${path#*://}"          # github.com/owner/repo
    path="${path#*/}"            # owner/repo, or just org
    local endpoint

    if [[ "${path}" == */* ]]; then
        endpoint="${api}/repos/${path}/actions/runners/registration-token"
    else
        endpoint="${api}/orgs/${path}/actions/runners/registration-token"
    fi

    log "minting a registration token from ${endpoint}"
    local resp
    resp="$(curl -fsSL -X POST \
        -H "Authorization: Bearer ${GITHUB_PAT}" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "${endpoint}")" \
        || { echo "Failed to mint a registration token. The PAT needs repo scope (or"  >&2
             echo "admin:org for an org runner), and GITHUB_REPO must name a repo you" >&2
             echo "can administer: ${GITHUB_REPO}"                                     >&2
             exit 1; }

    RUNNER_TOKEN="$(jq -r '.token // empty' <<< "${resp}")"
    [[ -n "${RUNNER_TOKEN}" ]] || { echo "No token in the API response" >&2; exit 1; }
}

if [[ -n "${GITHUB_PAT:-}" && ! -f .runner ]]; then
    mint_registration_token
fi

deregister() {
    [[ -f .runner ]] || return 0
    if [[ -z "${RUNNER_TOKEN:-}" ]]; then
        log "no token retained — leaving the registration in place"
        return 0
    fi
    log "deregistering runner"
    # A registration token is short-lived; if the container ran for more than an
    # hour this fails, and that is not worth aborting shutdown over.
    ./config.sh remove --token "${RUNNER_TOKEN}" \
        || log "deregistration failed (the token has most likely expired)"
}

if [[ ! -f .runner ]]; then
    if [[ -z "${GITHUB_REPO:-}" || -z "${RUNNER_TOKEN:-}" ]]; then
        echo "Missing GITHUB_REPO or RUNNER_TOKEN (or RUNNER_TOKEN_FILE)" >&2
        exit 1
    fi

    log "registering runner: ${RUNNER_NAME}"

    CONFIG_CMD=(
        ./config.sh
        --url "${GITHUB_REPO}"
        --token "${RUNNER_TOKEN}"
        --name "${RUNNER_NAME}"
        --unattended
        --replace
    )

    # Self-update is disabled by default: this is a community riscv64 port, and
    # the updater would fetch the official actions/runner package, which exists
    # only for x64/arm64/arm. Letting it "upgrade" replaces a working runner
    # with binaries that cannot execute on this machine.
    if [[ "${RUNNER_ALLOW_UPDATE:-false}" != "true" ]]; then
        CONFIG_CMD+=( --disableupdate )
    fi

    # One job per registration. This is the single most effective hardening
    # setting for a self-hosted runner: no workspace leftovers, no poisoned
    # tool cache, and no stolen .credentials reused across jobs.
    if [[ "${RUNNER_EPHEMERAL:-false}" == "true" ]]; then
        log "ephemeral mode: this runner will accept exactly one job"
        CONFIG_CMD+=( --ephemeral )
    fi

    if [[ -n "${RUNNER_LABELS:-}" ]]; then
        log "labels: ${RUNNER_LABELS}"
        CONFIG_CMD+=( --labels "${RUNNER_LABELS}" )
    fi

    if [[ -n "${RUNNER_GROUP:-}" ]]; then
        CONFIG_CMD+=( --runnergroup "${RUNNER_GROUP}" )
    fi

    if [[ -n "${RUNNER_WORKDIR:-}" ]]; then
        CONFIG_CMD+=( --work "${RUNNER_WORKDIR}" )
    fi

    "${CONFIG_CMD[@]}"
fi

log "starting GitHub Actions runner"

# Every workflow step is a descendant of run.sh and inherits its environment, so
# the registration token must not be in it. `env -u` strips it from the child
# without losing it here, which the deregistration path below still needs.
if [[ "${RUNNER_DEREGISTER:-false}" == "true" ]]; then
    env -u RUNNER_TOKEN -u RUNNER_TOKEN_FILE -u GITHUB_PAT -u GITHUB_PAT_FILE ./run.sh &
    RUN_PID=$!

    forward() { kill -TERM "${RUN_PID}" 2>/dev/null || true; }
    trap forward TERM INT

    # A trap makes `wait` return >128 before the child has actually exited, so
    # loop until run.sh has finished draining whatever job it was running.
    status=0
    while :; do
        # `rc=$?` after a closed `if` reads the if-statement's own status, not
        # the condition's — capture it on the || instead.
        rc=0
        wait "${RUN_PID}" || rc=$?
        if (( rc <= 128 )) || ! kill -0 "${RUN_PID}" 2>/dev/null; then
            status="${rc}"
            break
        fi
    done

    deregister
    exit "${status}"
else
    unset RUNNER_TOKEN RUNNER_TOKEN_FILE GITHUB_PAT GITHUB_PAT_FILE
    exec ./run.sh
fi

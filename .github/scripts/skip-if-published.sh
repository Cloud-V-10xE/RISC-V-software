#!/usr/bin/env bash
# Stops a build early when the exact asset it would produce is already
# published, so the runner is not spent recompiling a byte-identical artifact.
#
# Upstream projects re-cut the same version more often than you would expect —
# GCC 15.2.0 has been published here several times — and every one of those
# rebuilds cost hours of the single Pioneer box for nothing.
#
# Usage, from inside a build-script, immediately after the version is resolved
# and BEFORE anything expensive (clone, download, compile):
#
#     . "$GITHUB_WORKSPACE/.github/scripts/skip-if-published.sh" \
#         "gcc-${GCC_RELEASE}-riscv64-linux.tar.gz"
#
# It must be sourced, not executed: on a match it exports SKIP_BUILD=true and
# exits the calling script with status 0. The reusable workflow keys its
# Verify/Upload/Publish/Pages steps off SKIP_BUILD, so the job ends green with
# nothing published rather than failing on a missing artifact.
#
# Set FORCE_REBUILD=true in the environment to build anyway.

_sip_asset="${1:-}"
if [ -z "$_sip_asset" ]; then
    echo "skip-if-published.sh: expected an asset name" >&2
    exit 1
fi

if [ "${FORCE_REBUILD:-false}" = "true" ]; then
    echo "FORCE_REBUILD=true — building ${_sip_asset} even if already published"
elif [ -z "${GITHUB_REPOSITORY:-}" ]; then
    # Outside Actions there is nothing to compare against; never block a build
    # just because the check could not run.
    echo "skip-if-published.sh: GITHUB_REPOSITORY unset, skipping the check" >&2
else
    # Unauthenticated on purpose: the repository is public, and handing a
    # repo-write token to a script that then runs upstream build systems is a
    # bad trade for one lookup.
    _sip_json="$(curl -fsSL --retry 3 --retry-delay 5 \
        "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?per_page=100" 2>/dev/null || true)"

    if [ -z "$_sip_json" ]; then
        echo "::warning::could not reach the releases API; building ${_sip_asset} anyway"
    else
        if command -v jq >/dev/null 2>&1; then
            _sip_hit="$(printf '%s' "$_sip_json" \
                | jq -r --arg n "$_sip_asset" \
                    '[.[].assets[]?.name] | map(select(. == $n)) | first // empty')"
        else
            # No jq: fall back to a literal match on the JSON field.
            if printf '%s' "$_sip_json" | grep -qF "\"name\":\"${_sip_asset}\"" \
               || printf '%s' "$_sip_json" | grep -qF "\"name\": \"${_sip_asset}\""; then
                _sip_hit="$_sip_asset"
            else
                _sip_hit=""
            fi
        fi

        if [ -n "$_sip_hit" ]; then
            echo "::notice::${_sip_asset} is already published — nothing to build."
            echo "Set FORCE_REBUILD=true to rebuild it anyway."
            if [ -n "${GITHUB_ENV:-}" ]; then
                echo "SKIP_BUILD=true" >> "$GITHUB_ENV"
            fi
            if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
                {
                    echo "### Build skipped"
                    echo
                    echo "\`${_sip_asset}\` is already published, so this run compiled nothing."
                } >> "$GITHUB_STEP_SUMMARY"
            fi
            exit 0
        fi
        echo "${_sip_asset} is not published yet — building."
    fi
fi

unset _sip_asset _sip_json _sip_hit

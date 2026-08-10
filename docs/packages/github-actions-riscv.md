# GitHub Actions Runner (RISC-V)

Self-hosted GitHub Actions runner container images for `linux/riscv64`, built around the riscv64 runner binary from [Cloud-V-10xE/github-runner-riscv](https://github.com/Cloud-V-10xE/github-runner-riscv/releases).

## Why prebuilt for RISC-V?

GitHub does not publish a riscv64 build of `actions/runner` — the official releases cover x64, arm64 and arm only. Running self-hosted Actions on RISC-V hardware therefore requires both a ported runner binary and a container image to run it in, and neither exists upstream.

## Tags

All four variants live in the same Docker Hub repository:

| Tag | Base | Docker support |
|---|---|---|
| `latest`, `ubuntu-<version>` | Ubuntu 24.04 | no |
| `debian-<version>` | Debian trixie | no |
| `docker-latest`, `docker-ubuntu-<version>` | Ubuntu 24.04 | yes |
| `docker-debian-<version>` | Debian trixie | yes |

`<version>` is the runner version, e.g. `2.336.0`.

> Debian images use **trixie**, not bookworm. `debian:bookworm` publishes no riscv64 manifest — trixie was the first Debian release carrying riscv64 as a release architecture.

## Usage

### Unprivileged (no Docker)

```bash
docker run -d --restart always \
  -e GITHUB_REPO="https://github.com/<owner>/<repo>" \
  -e RUNNER_TOKEN="<registration-token>" \
  -e RUNNER_NAME="riscv-runner-1" \
  -e RUNNER_LABELS="riscv64,self-hosted" \
  cloudv10x/github-actions-riscv:latest
```

### With Docker support

Bind-mount the host's Docker socket. The entrypoint aligns the container's `docker` group GID with the socket's owner at startup, so `runneruser` can drive Docker regardless of the host's GID.

```bash
docker run -d --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_REPO="https://github.com/<owner>/<repo>" \
  -e RUNNER_TOKEN="<registration-token>" \
  -e RUNNER_NAME="riscv-runner-1" \
  -e RUNNER_LABELS="riscv64,self-hosted,docker" \
  cloudv10x/github-actions-riscv:docker-latest
```

## Environment variables

| Variable | Required | Purpose |
|---|---|---|
| `GITHUB_REPO` | yes | Repository or org URL to register against |
| `RUNNER_TOKEN` | yes | Registration token from Settings → Actions → Runners |
| `RUNNER_NAME` | no | Runner name (defaults to the container hostname) |
| `RUNNER_LABELS` | no | Comma-separated labels passed to `config.sh --labels` |

Registration state is written to `/home/runner/.runner`. Mount that path as a volume if you want the runner to survive recreation without re-registering.

## Build cadence

The image is rebuilt **only when `Cloud-V-10xE/github-runner-riscv` publishes a new release**. A daily job on a free x86 runner compares the upstream version against the tags already on Docker Hub, and the riscv64 runner is only used when there is genuinely something new to build.

The runner version is derived from the release *asset* name (`actions-runner-linux-riscv64-X.Y.Z.tar.gz`) rather than the git tag, because the tag carries a `-riscv64-net8` suffix that is not guaranteed stable.

## License

The runner itself is MIT (see [actions/runner](https://github.com/actions/runner/blob/main/LICENSE)); the packaging in this repository is MIT.

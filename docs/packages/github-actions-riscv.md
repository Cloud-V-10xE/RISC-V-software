# GitHub Actions Runner (RISC-V)

Self-hosted GitHub Actions runner container images for `linux/riscv64`, built around the riscv64 runner binary from [Cloud-V-10xE/github-runner-riscv](https://github.com/Cloud-V-10xE/github-runner-riscv/releases).

## Why prebuilt for RISC-V?

GitHub does not publish a riscv64 build of `actions/runner` — the official releases cover x64, arm64 and arm only. Running self-hosted Actions on RISC-V hardware therefore requires both a ported runner binary and a container image to run it in, and neither exists upstream.

## Tags

Both variants live in the same Docker Hub repository:

| Tag | Base | Docker support |
|---|---|---|
| `latest`, `ubuntu-<version>` | Ubuntu 24.04 LTS | no |
| `docker-latest`, `docker-ubuntu-<version>` | Ubuntu 24.04 LTS | yes — dind or host daemon |

`<version>` is the runner version, e.g. `2.336.0`.

## Why Ubuntu 24.04 only

Both images are built on **Ubuntu 24.04 LTS (glibc 2.39)**, deliberately — there is no Debian variant.

Debian trixie ships **glibc 2.41**. Anything compiled inside a trixie-based runner links against `GLIBC_2.41` symbols and then fails to start on Ubuntu 24.04 with `version 'GLIBC_2.41' not found`. Since every package in this archive is built on `ubuntu-24.04-riscv`, pinning the runner image to the same base means a binary produced inside one of these containers runs anywhere 24.04 runs.

glibc is backward compatible, not forward compatible: build on the *oldest* glibc you intend to support.

## Docker modes

The Docker-capable image supports two very different arrangements, selected with `DOCKER_MODE`. It defaults to `auto`: a bind-mounted socket means `host`, otherwise `dind` if the container is privileged enough to run a daemon, otherwise `none`.

| Mode | What jobs talk to | Needs | Isolation from the host |
|---|---|---|---|
| `host` | the host's dockerd, via the bind-mounted socket | `-v /var/run/docker.sock:...` | **none** — root-equivalent on the host |
| `dind` | a private dockerd inside the container | `--privileged` | full — its own images, containers and networks |
| `none` | nothing | — | n/a |

Pick `dind` unless you specifically want to share the host's layer cache and have only trusted workflows.

The image ships `docker` 29.x, `docker buildx` and `docker compose`, all from `noble-updates` — so `docker/setup-buildx-action` and BuildKit-syntax Dockerfiles work in both modes.

### dind (recommended)

```bash
docker run -d --restart always --privileged --init \
  --name riscv-runner-1 \
  --stop-timeout 120 \
  -v runner-docker-lib:/var/lib/docker \
  -e DOCKER_MODE=dind \
  -e GITHUB_REPO="https://github.com/<owner>/<repo>" \
  -e GITHUB_PAT="<pat with repo scope>" \
  -e RUNNER_NAME="riscv-runner-1" \
  -e RUNNER_LABELS="riscv64,self-hosted,docker" \
  -e RUNNER_EPHEMERAL=true \
  cloudv10x/github-actions-riscv:docker-latest
```

#### Never pair `RUNNER_EPHEMERAL` with a static `RUNNER_TOKEN`

A registration token is **single-use and expires in about an hour**. An ephemeral
runner deletes its own registration after one job and exits; `--restart always`
then brings the container back into a *re-registration* that the spent token
cannot satisfy. GitHub answers `404 Not Found` and the container crash-loops:

```
Http response code: NotFound from 'POST https://api.github.com/actions/runner-registration'
```

Pass `GITHUB_PAT` (or `GITHUB_PAT_FILE`) instead, as above. The entrypoint then
mints a fresh registration token on every start, which is what makes ephemeral
mode survive restarts at all. The PAT needs `repo` scope for a repository runner
or `admin:org` for an org runner, and — like the registration token — it is
scrubbed from the environment before any workflow step runs.

Without a PAT, use a long-lived runner: pass `RUNNER_TOKEN` and leave
`RUNNER_EPHEMERAL` unset.

`--privileged` is genuinely required, not a shortcut. `--cap-add SYS_ADMIN --cap-add NET_ADMIN` gets dockerd far enough to *start* and then fails at the first build:

```
runc run failed: unable to apply cgroup configuration:
  mkdir /sys/fs/cgroup/docker: read-only file system
```

The entrypoint therefore checks all four prerequisites — `CAP_SYS_ADMIN`, `CAP_NET_ADMIN`, writable `/proc/sys`, writable `/sys/fs/cgroup` — up front and refuses to start rather than failing inside someone's job.

The named volume on `/var/lib/docker` matters just as much. overlay2 cannot stack on an overlay2 upper dir, so without a real filesystem there dockerd falls back to `vfs`, which copies every layer on every build — the difference between a two-minute build and an hour on SG2042. The image declares `VOLUME /var/lib/docker` so this degrades to an anonymous volume rather than to vfs, but a named volume also keeps the layer cache across restarts.

`--init` reaps the processes builds leave behind, and `--stop-timeout 120` gives the runner room to finish the job it is holding before Docker escalates to SIGKILL — the default is 10 seconds, which is long enough to lose a build.

#### Preflight on the host

dind runs on the *host's* kernel, so if Docker already works on the box, the inner daemon almost certainly will too. Confirm before deploying a runner:

```bash
uname -m                                   # riscv64
stat -fc %T /sys/fs/cgroup                 # cgroup2fs — v1 will not delegate cleanly
docker info --format '{{.Driver}} {{.CgroupVersion}} {{.KernelVersion}}'
grep -q overlay /proc/filesystems && echo "overlayfs present"
docker run --rm --privileged ubuntu:24.04 true && echo "privileged containers allowed"
```

`overlay2` plus `cgroup2fs` on the host is the combination that matters. Keep `/var/lib/docker` on ext4 — the Pioneer's default root filesystem is fine, and overlay2 will not run on top of every filesystem.

### host (docker-out-of-docker)

```bash
docker run -d --restart always --init \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/runner/_work:/home/runner/_work \
  -e DOCKER_MODE=host \
  -e GITHUB_REPO="https://github.com/<owner>/<repo>" \
  -e RUNNER_TOKEN="<registration-token>" \
  -e RUNNER_LABELS="riscv64,self-hosted,docker" \
  cloudv10x/github-actions-riscv:docker-latest
```

The entrypoint aligns the container's `docker` group with the socket's owner at startup, so `runneruser` can drive Docker whatever the host's GID is.

**The `_work` bind-mount is not optional.** The daemon resolves volume paths in the *host's* namespace, so a step doing `docker run -v "$PWD:/src"`, or any job using `jobs.<id>.container:` or `services:`, mounts a host path that does not exist. Mounting the work directory at the identical path on both sides is what makes those resolve to the same files. Nothing warns you when this is missing — the container just sees an empty directory.

### Unprivileged (no Docker)

```bash
docker run -d --restart always \
  -e GITHUB_REPO="https://github.com/<owner>/<repo>" \
  -e RUNNER_TOKEN="<registration-token>" \
  -e RUNNER_NAME="riscv-runner-1" \
  -e RUNNER_LABELS="riscv64,self-hosted" \
  cloudv10x/github-actions-riscv:latest
```

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `GITHUB_REPO` | — | **Required.** Repository or org URL to register against |
| `RUNNER_TOKEN` | — | Registration token from Settings → Actions → Runners. Required unless `GITHUB_PAT` is set |
| `RUNNER_TOKEN_FILE` | — | Read the token from a mounted file instead — keeps it out of `docker inspect` |
| `GITHUB_PAT` | — | PAT (`repo`, or `admin:org` for org runners) used to mint a fresh registration token on every start. Required for `RUNNER_EPHEMERAL` with `--restart` |
| `GITHUB_PAT_FILE` | — | Read the PAT from a mounted file instead |
| `GITHUB_API_URL` | `https://api.github.com` | API base, for GitHub Enterprise Server |
| `RUNNER_NAME` | container hostname | Runner name |
| `RUNNER_LABELS` | — | Comma-separated labels passed to `config.sh --labels` |
| `RUNNER_GROUP` | — | Runner group to register into |
| `RUNNER_WORKDIR` | `_work` | Work directory |
| `RUNNER_EPHEMERAL` | `false` | Accept exactly one job, then exit |
| `RUNNER_DEREGISTER` | `false` | Remove the registration on SIGTERM |
| `RUNNER_ALLOW_UPDATE` | `false` | Allow runner self-update — see below |
| `RUNNER_NO_NEW_PRIVS` | `false` | Set `no_new_privs`; blocks all setuid binaries, `sudo` included |
| `DOCKER_MODE` | `auto` | `auto`, `host`, `dind` or `none` |
| `DOCKER_STORAGE_DRIVER` | `overlay2` | dind storage driver |
| `DOCKERD_EXTRA_ARGS` | — | Extra flags for the inner dockerd |
| `DOCKER_START_TIMEOUT` | `90` | Seconds to wait for the inner dockerd |

Registration state is written to `/home/runner/.runner`. Mount that path as a volume if you want the runner to survive recreation without re-registering.

### Self-update is disabled by default

`config.sh` is invoked with `--disableupdate` unless `RUNNER_ALLOW_UPDATE=true`. The updater fetches the *official* `actions/runner` package, which is published only for x64, arm64 and arm — letting it run replaces a working riscv64 runner with binaries that cannot execute on the machine. Only set this if you have a riscv64 update feed.

## Security notes

What the image does:

- **Runs as `runneruser` (uid 1001), never root.** The Docker-capable entrypoint starts as root only to prepare the daemon, then drops via `setpriv --init-groups --inh-caps=-all` and never returns.
- **Keeps the registration token out of workflows.** `RUNNER_TOKEN` is scrubbed from the environment before `run.sh` starts, so it is not inherited by every step. It never appears in a command line either — the previous entrypoint interpolated it into a `su -c` string, where `ps` exposed it for the life of the container.
- **Owns its own entrypoint.** `/usr/local/bin/*.sh` is root-owned and not writable by `runneruser`, so a compromised job cannot rewrite what runs at the next container start.
- **Verifies the runner tarball** against the release digest when the API publishes one (`RUNNER_SHA256`).
- **Joins the socket's group instead of deleting it.** The old entrypoint ran `groupdel` on whichever group happened to hold the socket's GID, which on Ubuntu collides with real system groups and orphans the files they own.

What is still on you:

- **`host` mode is a host takeover primitive.** Any workflow that lands on the runner can `docker run -v /:/host --privileged` and own the box. Never point it at a repository that accepts fork pull requests; use `dind` there.
- **`.credentials` is readable by jobs.** It holds the long-lived runner key, and jobs run as the same user that owns it, so any job can steal the registration. `RUNNER_EPHEMERAL=true` plus a fresh container per job is the mitigation — it also clears the workspace and tool cache between jobs.
- **Passwordless `sudo` is on by default**, because jobs in this archive install their own build deps. Build with `--build-arg RUNNER_SUDO=false` for runners taking untrusted work; `RUNNER_NO_NEW_PRIVS=true` enforces the same thing at runtime.
- **`--privileged` dind is not a security boundary against a determined attacker.** It is a much better boundary than a bind-mounted host socket, but a privileged container can still reach the host kernel.

## Build cadence

The image is rebuilt **only when `Cloud-V-10xE/github-runner-riscv` publishes a new release**. A daily job on a free x86 runner compares the upstream version against the tags already on Docker Hub, and the riscv64 runner is only used when there is genuinely something new to build.

The runner version is derived from the release *asset* name (`actions-runner-linux-riscv64-X.Y.Z.tar.gz`) rather than the git tag, because the tag carries a `-riscv64-net8` suffix that is not guaranteed stable.

## Layout

```
runner-image/
├── common/runner.sh              registration + run.sh, always as runneruser
├── docker-in-docker/             Docker-capable variant
│   ├── Dockerfile.ubuntu
│   └── entrypoint.sh             root: prepares docker, then drops privileges
└── unprivileged/Dockerfile.ubuntu
```

`common/runner.sh` is shared, so the build context is `runner-image/` and not the variant directory. Registration flags are exactly the kind of thing that drifts when two copies exist.

## License

The runner itself is MIT (see [actions/runner](https://github.com/actions/runner/blob/main/LICENSE)); the packaging in this repository is MIT.

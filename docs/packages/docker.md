# Docker Engine

Docker Engine — the `dockerd` daemon, the `docker` CLI, and `docker-proxy`.

## Why prebuilt for RISC-V?

`download.docker.com` has **no riscv64 directory at all**. The static-binary tree carries aarch64, armel, armhf, ppc64le, s390x and x86_64; the apt repo for noble is amd64/arm64/armhf/ppc64el/s390x. `moby/moby`'s GitHub releases carry zero assets.

Ubuntu's `noble` release pocket carries `docker.io` **24.0.7** for riscv64, against upstream 29.x.

`noble-updates` has since caught up: it carries riscv64 `docker.io` **29.1.3**, `docker-buildx` **0.30.1** and `docker-compose-v2` **2.40.3**. If you are on 24.04 and Ubuntu's packaging and cadence suit you, `apt-get install docker.io docker-buildx docker-compose-v2` is now a working option — the runner images in this repository use exactly that. This package remains the way to get a current upstream `dockerd` built from source, on any distribution.

## Scope

This package deliberately builds **only what is actually missing**. Compose, Buildx, BuildKit and nerdctl already publish riscv64 binaries upstream:

| Component | Where to get riscv64 |
|---|---|
| `dockerd`, `docker`, `docker-proxy` | **this package** |
| `docker compose` | [docker/compose](https://github.com/docker/compose) releases |
| `docker buildx` | [docker/buildx](https://github.com/docker/buildx) releases |
| `buildkitd` | [moby/buildkit](https://github.com/moby/buildkit) releases |
| `containerd`, `runc` | your distro, or upstream containerd releases |

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-software/releases/latest/download/docker-<version>-riscv64-linux.tar.gz
tar -xzf docker-<version>-riscv64-linux.tar.gz -C /usr/local/
dockerd --version
```

`dockerd` additionally needs `containerd` and `runc` present on the system.

## License

Apache-2.0 — https://github.com/moby/moby/blob/master/LICENSE

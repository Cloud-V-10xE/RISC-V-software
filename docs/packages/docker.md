# Docker Engine

Docker Engine — the `dockerd` daemon, the `docker` CLI, and `docker-proxy`.

## Why prebuilt for RISC-V?

`download.docker.com` has **no riscv64 directory at all**. The static-binary tree carries aarch64, armel, armhf, ppc64le, s390x and x86_64; the apt repo for noble is amd64/arm64/armhf/ppc64el/s390x. `moby/moby`'s GitHub releases carry zero assets.

Ubuntu 24.04 riscv64 is stuck on `docker.io` **24.0.7** against upstream 29.x, and ships no `docker-compose-plugin` or `docker-buildx-plugin` for riscv64 at all.

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

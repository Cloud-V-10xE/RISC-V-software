# Helm — Kubernetes Package Manager

Helm is the package manager for Kubernetes, allowing you to define, install, and upgrade complex Kubernetes applications using charts.

## Why prebuilt for RISC-V?

Helm's official GitHub releases do not include riscv64 binaries. Every Kubernetes operator on a RISC-V node needs Helm to deploy applications. This prebuilt binary enables Helm usage on riscv64 nodes without requiring a Go toolchain to build it.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/helm-<version>-riscv64-linux.tar.gz
sudo tar -xzf helm-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
helm version
helm repo add stable https://charts.helm.sh/stable
helm install my-release stable/nginx-ingress
helm list
```

## License

Apache-2.0 — https://github.com/helm/helm/blob/main/LICENSE

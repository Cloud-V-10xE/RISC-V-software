# containerd — Container Runtime

containerd is an industry-standard container runtime used by Docker, Kubernetes (via CRI), and many other container platforms. It manages the complete container lifecycle.

## Why prebuilt for RISC-V?

containerd has no official riscv64 binary in its GitHub releases. It is a fundamental requirement for running Kubernetes on RISC-V — every worker node needs containerd as its CRI runtime. This prebuilt binary is a direct dependency for any RISC-V Kubernetes deployment.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/containerd-<version>-riscv64-linux.tar.gz
sudo tar -xzf containerd-<version>-riscv64-linux.tar.gz -C /usr/local/
sudo systemctl enable --now containerd
```

## Included Binaries

`containerd`, `containerd-shim`, `containerd-shim-runc-v2`, `ctr`

## License

Apache-2.0 — https://github.com/containerd/containerd/blob/main/LICENSE

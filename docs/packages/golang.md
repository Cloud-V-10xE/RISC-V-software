# Go — Programming Language Toolchain

Go is a statically typed, compiled language designed for simplicity and concurrency. Used by Docker, Kubernetes, Terraform, and much of the cloud-native ecosystem.

## Why prebuilt for RISC-V?

The official Go releases at go.dev/dl do not include riscv64 binaries. Every Go-based project (Helm, containerd, fzf, etc.) requires a Go toolchain to build. This prebuilt binary enables Go development and bootstraps building other Go projects on RISC-V hardware.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/golang-<version>-riscv64-linux.tar.gz
sudo tar -xzf golang-<version>-riscv64-linux.tar.gz -C /usr/local/
export PATH=/usr/local/go/bin:$PATH
```

## Usage

```bash
go version
go build ./...
go test ./...
```

## License

BSD-3-Clause — https://github.com/golang/go/blob/master/LICENSE

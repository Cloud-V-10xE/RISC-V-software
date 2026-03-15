<div align="center">

<img src="https://riscv.org/wp-content/uploads/2020/06/riscv-color.svg" height="80" alt="RISC-V Logo"/>

# RISC-V Software Archive

**Prebuilt binaries for RISC-V 64-bit Linux — built natively on real hardware**

[![Packages](https://img.shields.io/badge/packages-20+-blue?style=flat-square)](#-packages)
[![Architecture](https://img.shields.io/badge/arch-riscv64-orange?style=flat-square)](#)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/site-live-brightgreen?style=flat-square)](https://cloud-v-10xe.github.io/RISC-V-softwares/)

---

[**📦 Browse Packages**](https://cloud-v-10xe.github.io/RISC-V-softwares/) · [**📖 Docs**](docs/) · [**🤝 Contribute**](CONTRIBUTING.md)

</div>

---

## Why this exists

Getting software running on RISC-V is harder than it should be. Official releases skip riscv64. Package managers ship outdated versions. Developers who need the latest GCC, Go, Python, or Kubernetes tooling on RISC-V hardware end up spending hours building from source.

This project solves that by building popular packages natively on real RISC-V hardware (Milk-V Pioneer, 64 cores) and publishing ready-to-use binaries — updated automatically every month.

---

## 📦 Packages

| Package | Category | Description |
|---------|----------|-------------|
| [GCC](https://cloud-v-10xe.github.io/RISC-V-softwares/gcc/) | Compilers | GNU Compiler Collection — latest versions not in apt |
| [Binutils](https://cloud-v-10xe.github.io/RISC-V-softwares/binutils/) | Compilers | GNU binary utilities |
| [Coreutils](https://cloud-v-10xe.github.io/RISC-V-softwares/coreutils/) | Compilers | GNU core utilities |
| [strace](https://cloud-v-10xe.github.io/RISC-V-softwares/strace/) | Compilers | System call tracer |
| [Node.js](https://cloud-v-10xe.github.io/RISC-V-softwares/nodejs/) | Runtimes | JavaScript runtime — no official riscv64 release |
| [OpenJDK](https://cloud-v-10xe.github.io/RISC-V-softwares/openjdk/) | Runtimes | Java Development Kit |
| [.NET SDK](https://cloud-v-10xe.github.io/RISC-V-softwares/dotnet-sdk/) | Runtimes | .NET SDK and runtime |
| [Python](https://cloud-v-10xe.github.io/RISC-V-softwares/python/) | Runtimes | Python 3.13 with performance improvements |
| [Ruby](https://cloud-v-10xe.github.io/RISC-V-softwares/ruby/) | Runtimes | Ruby — latest versions not prebuilt for riscv64 |
| [Go](https://cloud-v-10xe.github.io/RISC-V-softwares/golang/) | Runtimes | Go toolchain — no official riscv64 binary |
| [PyTorch](https://cloud-v-10xe.github.io/RISC-V-softwares/pytorch/) | ML Frameworks | Machine learning framework by Meta |
| [TensorFlow](https://cloud-v-10xe.github.io/RISC-V-softwares/tensorflow/) | ML Frameworks | Machine learning platform by Google |
| [Transformers](https://cloud-v-10xe.github.io/RISC-V-softwares/transformers/) | ML Frameworks | Hugging Face Transformers |
| [ONNX Runtime](https://cloud-v-10xe.github.io/RISC-V-softwares/onnxruntime/) | ML Frameworks | Cross-platform ML inference |
| [Bazelisk](https://cloud-v-10xe.github.io/RISC-V-softwares/bazelisk/) | Build Tools | Bazel launcher |
| [CMake](https://cloud-v-10xe.github.io/RISC-V-softwares/cmake/) | Build Tools | Cross-platform build system |
| [Ninja](https://cloud-v-10xe.github.io/RISC-V-softwares/ninja/) | Build Tools | Fast build system |
| [fzf](https://cloud-v-10xe.github.io/RISC-V-softwares/fzf/) | Build Tools | Command-line fuzzy finder |
| [zstd](https://cloud-v-10xe.github.io/RISC-V-softwares/zstd/) | Build Tools | Fast compression algorithm |
| [Kubernetes](https://cloud-v-10xe.github.io/RISC-V-softwares/kubernetes/) | Infrastructure | Container orchestration |
| [Helm](https://cloud-v-10xe.github.io/RISC-V-softwares/helm/) | Infrastructure | Kubernetes package manager |
| [containerd](https://cloud-v-10xe.github.io/RISC-V-softwares/containerd/) | Infrastructure | Container runtime |
| [Protobuf](https://cloud-v-10xe.github.io/RISC-V-softwares/protobuf/) | Infrastructure | Protocol Buffers compiler |
| [gRPC](https://cloud-v-10xe.github.io/RISC-V-softwares/grpc/) | Infrastructure | High-performance RPC framework |
| [SQLite](https://cloud-v-10xe.github.io/RISC-V-softwares/sqlite/) | Infrastructure | Embedded SQL database |

> Docker images (Flannel, etcd, Kubernetes components) are published to [GitHub Container Registry](https://github.com/orgs/Cloud-V-10xE/packages).

---

## 🚀 Quick Start

### Download a binary

Visit the [package archive](https://cloud-v-10xe.github.io/RISC-V-softwares/) and download the version you need, or use `wget` directly from a release:

```bash
# Example: install the latest GCC
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/download/<tag>/gcc-<version>-riscv64-linux.tar.gz
tar -xzf gcc-<version>-riscv64-linux.tar.gz -C /usr/local/
```

### Use a Docker image

All Docker images are multi-arch (amd64 + riscv64):

```bash
# Pull a Kubernetes component image
docker pull ghcr.io/cloud-v-10xe/kube-apiserver:latest
```

---

## 🏗️ How it works

```
┌─────────────────────────────────────────────────────┐
│                   GitHub Actions                     │
│                                                      │
│  Individual build workflows (build-gcc.yml etc.)     │
│       │                                              │
│       ▼  runs on                                     │
│  ┌─────────────┐        ┌──────────────────────┐    │
│  │ Milk-V      │        │  ubuntu-latest (x86) │    │
│  │ Pioneer Box │        │  for Docker images   │    │
│  │ (riscv64)   │        └──────────────────────┘    │
│  └─────────────┘                                     │
│       │                                              │
│       ▼  uploads artifact                            │
│  Central Release workflow (daily)                    │
│       │                                              │
│       ▼  creates GitHub release                      │
│  GitHub Releases ──────► GitHub Pages site           │
└─────────────────────────────────────────────────────┘
```

Each package has its own workflow file in `.github/workflows/`. Binaries are built natively on a Milk-V Pioneer box (64-core RISC-V, 128GB RAM). The central release workflow runs daily, collects the latest successful artifact from each build workflow, and bundles them into a single GitHub release. The GitHub Pages site regenerates automatically after each release.

See [docs/architecture.md](docs/architecture.md) for a detailed explanation.

---

## 🤝 Contributing

Want to add a new package or fix a failing build? See [CONTRIBUTING.md](CONTRIBUTING.md) for a step-by-step guide.

The short version:

1. Add an entry to `.github/pages/packages.json`
2. Add a workflow file `.github/workflows/build-<package>.yml`
3. Add documentation to `docs/packages/<package>.md`
4. Open a pull request

---

## 📄 License

The workflow files, tooling, and documentation in this repository are licensed under the [MIT License](LICENSE).

Each prebuilt binary retains its own upstream license. See [NOTICES.md](NOTICES.md) for the full list.

---

<div align="center">
Built with ❤️ by <a href="https://github.com/Cloud-V-10xE">Cloud-V</a> on real RISC-V hardware
</div>

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

This project solves that by building popular packages natively on [RISE Runners](https://github.com/apps/rise-risc-v-runners) and publishing ready-to-use binaries which are updated automatically every month.

---

## 🚀 Quick Start

### Download a binary

Visit the [package archive](https://cloud-v-10xe.github.io/RISC-V-software/) and download the version you need, or use `wget` directly from a release:

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
│  ┌─────────────┐        ┌──────────────────────┐     │
│  │    RISE     │        │  ubuntu-latest (x86) │     │
│  │             │        │  for Docker images   │     │
│  │   Runners   │        └──────────────────────┘     │
│  └─────────────┘                                     │
│       │                                              │
│       ▼  uploads artifact                            │
│  Central Release workflow (daily)                    │
│       │                                              │
│       ▼  creates GitHub release                      │
│  GitHub Releases ──────► GitHub Pages site           │
└─────────────────────────────────────────────────────┘
```

Each package has its own workflow file in `.github/workflows/`. The central release workflow runs daily, collects the latest successful artifact from each build workflow, and bundles them into a single GitHub release. The GitHub Pages site regenerates automatically after each release.

See [docs/architecture.md](docs/architecture.md) for a detailed explanation.

---

## Contributing

Want to add a new package or fix a failing build? See [CONTRIBUTING.md](CONTRIBUTING.md) for a step-by-step guide.

The short version:

1. Add an entry to `.github/pages/packages.json`
2. Add a workflow file `.github/workflows/build-<package>.yml`
3. Add documentation to `docs/packages/<package>.md`
4. Open a pull request

---

## 📄 License

The workflow files, tooling, and documentation in this repository are licensed under the [MIT License](LICENSE).

Each prebuilt binary retains its own upstream license.

---

<div align="center">
Built with ❤️ by <a href="https://github.com/Cloud-V-10xE">Cloud-V</a>
</div>

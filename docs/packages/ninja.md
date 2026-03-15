# Ninja — Fast Build System

Ninja is a small, focused build system designed for speed. Used as the backend for CMake, Meson, and the Chromium/LLVM build systems.

## Why prebuilt for RISC-V?

`apt install ninja-build` exists but ships older versions. More importantly, when building Ninja as part of a bootstrapped toolchain environment, having a prebuilt binary avoids circular dependencies. Ninja is a prerequisite for building LLVM, CMake from source, and many other tools.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/ninja-<version>-riscv64-linux.tar.gz
sudo tar -xzf ninja-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
ninja --version
# Use with CMake:
cmake -B build -G Ninja
ninja -C build
```

## License

Apache-2.0 — https://github.com/ninja-build/ninja/blob/master/COPYING

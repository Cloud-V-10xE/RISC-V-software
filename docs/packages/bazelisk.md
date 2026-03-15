# Bazelisk — Bazel Launcher

Bazelisk is a user-friendly launcher for Bazel that automatically downloads and runs the correct Bazel version for your project.

## Why prebuilt for RISC-V?

Bazel has no official riscv64 binary. Bazelisk (the launcher) also has no official riscv64 release. Both TensorFlow and many other large projects require Bazel to build. This prebuilt binary is the entry point for building any Bazel-based project on RISC-V.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/bazelisk-<version>-riscv64-linux.tar.gz
tar -xzf bazelisk-<version>-riscv64-linux.tar.gz
sudo mv bin/bazel /usr/local/bin/bazel
chmod +x /usr/local/bin/bazel
```

## Usage

```bash
bazel --version
bazel build //...
bazel test //...
```

## License

Apache-2.0 — https://github.com/bazelbuild/bazelisk/blob/master/LICENSE

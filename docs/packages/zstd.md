# Zstd — Fast Lossless Compression

Zstandard (zstd) is a real-time compression algorithm offering high compression ratios at very high speeds. Used by the Linux kernel, Docker, Facebook's infrastructure, and many package managers.

## Why prebuilt for RISC-V?

While `apt install zstd` exists, it ships older versions. More critically, zstd is needed as a build dependency for many other packages (kernel builds, Docker images, package managers) and having the latest version ensures compatibility with newer compression levels and dictionary formats.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/zstd-<version>-riscv64-linux.tar.gz
sudo tar -xzf zstd-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
zstd --version
zstd file.tar          # compress
zstd -d file.tar.zst   # decompress
zstd -19 file.tar      # max compression
```

## License

BSD-3-Clause / GPL-2.0 — https://github.com/facebook/zstd/blob/dev/LICENSE

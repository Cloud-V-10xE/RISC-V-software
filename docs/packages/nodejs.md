# Node.js — JavaScript Runtime

Node.js is a JavaScript runtime built on Chrome's V8 engine, used for server-side JavaScript, build tooling, and CLI applications.

## Why prebuilt for RISC-V?

The official Node.js releases at nodejs.org do not include riscv64 binaries. Developers running JavaScript tooling (npm, webpack, vite, etc.) on RISC-V hardware must either build from source (2+ hours) or go without. This build provides the latest LTS version natively compiled for riscv64.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/nodejs-<version>-riscv64-linux.tar.gz
sudo tar -xzf nodejs-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
node --version
npm --version
npm install
```

## License

MIT — https://github.com/nodejs/node/blob/main/LICENSE

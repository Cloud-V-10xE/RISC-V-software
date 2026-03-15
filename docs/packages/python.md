# Python 3.13

Python 3.13 is the latest stable release of the Python programming language, featuring significant performance improvements from the "faster CPython" project.

## Why prebuilt for RISC-V?

`apt install python3` on Ubuntu Noble gives Python 3.12. Python 3.13 introduces a free-threaded mode (no GIL), a new REPL, improved error messages, and up to 60% speedup on some workloads. No official prebuilt riscv64 binary exists for 3.13.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/python-<version>-riscv64-linux.tar.gz
sudo tar -xzf python-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
python3.13 --version
python3.13 -m pip install numpy
```

## License

PSF-2.0 — https://docs.python.org/3/license.html

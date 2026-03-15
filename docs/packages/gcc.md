# GCC — GNU Compiler Collection

GCC is the standard compiler for Linux systems, supporting C, C++, Fortran, Go, and more.

## Why prebuilt for RISC-V?

`apt install gcc` on Ubuntu Noble gives you GCC 13. GCC 14 and 15 include significant RISC-V specific optimizations — better vectorization using the V extension, improved code generation for the RVA22 profile, and new intrinsics. Developers targeting modern RISC-V hardware need these newer versions but cannot get them from package managers.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/gcc-<version>-riscv64-linux.tar.gz
sudo tar -xzf gcc-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
gcc --version
g++ --version
gfortran --version
```

## License

GPL-3.0 — https://gcc.gnu.org/onlinedocs/gcc/Copying.html

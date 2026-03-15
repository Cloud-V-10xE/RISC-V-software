# CMake — Cross-Platform Build System

CMake is the de facto standard build system generator for C and C++ projects. It generates build files for Make, Ninja, Visual Studio, and more.

## Why prebuilt for RISC-V?

`apt install cmake` on Ubuntu Noble gives CMake 3.28. Many projects require CMake 3.30+ for features like CMake presets v7, improved CUDA support, and new find_package behavior. No prebuilt riscv64 binary exists from Kitware for newer versions.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/cmake-<version>-riscv64-linux.tar.gz
sudo tar -xzf cmake-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
cmake --version
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel $(nproc)
cmake --install build
```

## License

BSD-3-Clause — https://cmake.org/licensing/

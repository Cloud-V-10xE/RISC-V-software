# Protobuf — Protocol Buffers

Protocol Buffers is Google's language-neutral, platform-neutral mechanism for serializing structured data. The `protoc` compiler generates code from `.proto` files.

## Why prebuilt for RISC-V?

No official riscv64 binary exists for protoc. Protobuf is a dependency of gRPC, TensorFlow, Kubernetes internals, and virtually every cloud-native project. Building it requires CMake and C++17 support. This prebuilt binary unblocks development of any project using proto files on RISC-V.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/protobuf-<version>-riscv64-linux.tar.gz
sudo tar -xzf protobuf-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Usage

```bash
protoc --version
protoc --python_out=. myproto.proto
protoc --go_out=. myproto.proto
```

## License

BSD-3-Clause — https://github.com/protocolbuffers/protobuf/blob/main/LICENSE

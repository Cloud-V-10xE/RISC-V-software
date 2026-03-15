# gRPC — High-Performance RPC Framework

gRPC is a modern, high-performance remote procedure call framework developed by Google. It uses Protocol Buffers for serialization and HTTP/2 for transport.

## Why prebuilt for RISC-V?

No prebuilt riscv64 gRPC binary exists anywhere. gRPC is required by Kubernetes (etcd communication), TensorFlow Serving, and nearly all cloud-native microservices. Building it requires protobuf, abseil, boringssl, and a C++17 compiler — a significant build-time dependency chain. This prebuilt binary eliminates that barrier.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/grpc-<version>-riscv64-linux.tar.gz
sudo tar -xzf grpc-<version>-riscv64-linux.tar.gz -C /usr/local/
```

## Included Binaries

`grpc_cpp_plugin`, `grpc_python_plugin`, `grpc_node_plugin` and shared libraries

## License

Apache-2.0 — https://github.com/grpc/grpc/blob/master/LICENSE

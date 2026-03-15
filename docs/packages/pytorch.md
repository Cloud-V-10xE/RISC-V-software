# PyTorch

PyTorch is an open-source machine learning framework by Meta, widely used for deep learning research and production deployment.

## Why prebuilt for RISC-V?

PyPI does not distribute riscv64 wheels for PyTorch. Building from source requires Bazel, hours of compilation, and careful dependency management. This prebuilt wheel enables ML workloads and inference on RISC-V hardware without that barrier.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/pytorch-<version>-riscv64-linux.tar.gz
tar -xzf pytorch-<version>-riscv64-linux.tar.gz
pip install torch-*.whl
```

## Usage

```python
import torch
print(torch.__version__)
x = torch.rand(3, 3)
print(x)
```

## License

BSD-3-Clause — https://github.com/pytorch/pytorch/blob/main/LICENSE

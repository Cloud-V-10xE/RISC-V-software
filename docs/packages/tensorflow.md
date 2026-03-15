# TensorFlow

TensorFlow is Google's open-source machine learning platform, used for building and deploying ML models at scale.

## Why prebuilt for RISC-V?

TensorFlow has no official riscv64 wheel on PyPI. Building requires Bazel (itself hard to get on RISC-V), custom patches, and hours of compilation. This prebuilt wheel is the only practical way to run TensorFlow on RISC-V hardware today.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/tensorflow-<version>-riscv64-linux.tar.gz
tar -xzf tensorflow-<version>-riscv64-linux.tar.gz
pip install tensorflow-*.whl
```

## Usage

```python
import tensorflow as tf
print(tf.__version__)
print(tf.constant("Hello, RISC-V"))
```

## License

Apache-2.0 — https://github.com/tensorflow/tensorflow/blob/master/LICENSE

# ONNX Runtime

ONNX Runtime is Microsoft's cross-platform ML inference engine, supporting models from PyTorch, TensorFlow, scikit-learn, and more via the ONNX format.

## Why prebuilt for RISC-V?

No riscv64 wheel exists on PyPI for onnxruntime. It is widely used for deploying quantized models efficiently — important for resource-constrained RISC-V deployments. This prebuilt wheel enables ONNX model inference without a multi-hour build from source.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/onnxruntime-<version>-riscv64-linux.tar.gz
tar -xzf onnxruntime-<version>-riscv64-linux.tar.gz
pip install onnxruntime-*.whl
```

## Usage

```python
import onnxruntime as ort
session = ort.InferenceSession("model.onnx")
outputs = session.run(None, {"input": input_data})
```

## License

MIT — https://github.com/microsoft/onnxruntime/blob/main/LICENSE

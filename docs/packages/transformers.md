# Hugging Face Transformers

The Transformers library provides thousands of pretrained models for NLP, vision, and audio tasks. The standard library for modern ML inference.

## Why prebuilt for RISC-V?

Transformers itself is pure Python but its dependencies (tokenizers, safetensors) have Rust extensions with no riscv64 wheels on PyPI. This prebuilt package bundles all dependencies compiled for riscv64, enabling LLM inference and model deployment on RISC-V hardware.

## Installation

```bash
wget https://github.com/Cloud-V-10xE/RISC-V-softwares/releases/latest/download/transformers-<version>-riscv64-linux.tar.gz
tar -xzf transformers-<version>-riscv64-linux.tar.gz
pip install *.whl
```

## Usage

```python
from transformers import pipeline
classifier = pipeline("sentiment-analysis")
result = classifier("RISC-V is the future of open hardware")
print(result)
```

## License

Apache-2.0 — https://github.com/huggingface/transformers/blob/main/LICENSE

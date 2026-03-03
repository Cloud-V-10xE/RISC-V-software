The Hugging Face Transformers library provides thousands of pretrained models for natural language processing, computer vision, and audio tasks. It offers a unified API to download, fine-tune, and run models from the Hugging Face Hub using PyTorch, TensorFlow, or JAX as backends.

This RISC-V build is a Python wheel compiled natively on riscv64 hardware, targeting Python 3.12. The backend is PyTorch — install the RISC-V PyTorch wheel first before installing this package.

Supported task categories include text classification, token classification, question answering, text generation, translation, summarization, image classification, automatic speech recognition, and more. Not all models are guaranteed to run on RISC-V — models with custom CUDA kernels or architecture-specific optimisations will not work. Standard transformer architectures such as BERT, GPT-2, T5, DistilBERT, and RoBERTa work as expected.

To verify the installation is working correctly, run a simple pipeline after installing: from transformers import pipeline; pipe = pipeline("text-classification"); print(pipe("This is a test"))

For inference on RISC-V, CPU memory is the primary constraint. Smaller models (under 1B parameters) are practical. Larger models can be run with reduced precision or model sharding but will be slow without hardware acceleration.

Requirements: RISC-V 64-bit Linux, Python 3.12, pip, PyTorch RISC-V wheel (install before this package), at least 2GB RAM for small models.

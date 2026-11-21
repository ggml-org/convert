---
license: other
pipeline_tag: text-generation
tags:
- gguf
- quantized
- speculative-decoding
base_model:
- Qwen/Qwen3.5-4B
- Qwen/Qwen3-4B
- Qwen/Qwen3.8-27B
- nvidia/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB
---

# Speculative decoding models for testing

Target and draft GGUFs used by llama.cpp speculative-decoding integration tests.
The repository includes coverage for MTP, DFlash, DSpark, EAGLE-3, DFlash2,
and LiLiCorr.

### Source models

- https://huggingface.co/Qwen/Qwen3.5-4B
- https://huggingface.co/Qwen/Qwen3-4B
- https://huggingface.co/z-lab/Qwen3-4B-DFlash-b16
- https://huggingface.co/deepseek-ai/dspark_qwen3_4b_block7
- https://huggingface.co/AngelSlim/Qwen3-4B_eagle3
- https://huggingface.co/Qwen/Qwen3.8-27B
- https://huggingface.co/incoai/Qwen3.8-27B-DFlash2
- https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB-GGUF
- https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB-LiLiCorr-GGUF

### Licenses

The files retain the licenses of their respective source models. Review each
source model card before use; the combined repository does not impose a single
license over all artifacts. In particular,
`deepseek-ai/dspark_qwen3_4b_block7` does not currently declare a license, so
its converted artifact must not be treated as having a cleared open-source
license.

> [!IMPORTANT]
> This model repository is automatically converted using
> https://github.com/ggml-org/convert

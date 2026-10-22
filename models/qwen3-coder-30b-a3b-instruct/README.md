---
license: apache-2.0
pipeline_tag: text-generation
tags:
- gguf
- quantized
base_model:
- Qwen/Qwen3-Coder-30B-A3B-Instruct
---

# Qwen3-Coder-30B-A3B-Instruct

Run with https://llama.app

```bash
llama serve -hf __owner__/Qwen3-Coder-30B-A3B-Instruct-GGUF
```

### Source models
- https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct

### Notes
- Ships `BF16`, `Q8_0` and `Q4_K_M`.
- 30B MoE (3B active), 48 layers, 128 routed experts with 8 active per token, 262K context.
- `Q8_0` and `Q4_K_M`: the routed experts use the base quantization type.
- In `Q4_K_M` the small non-expert tensors (embeddings, attention) are kept at Q8_0.

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

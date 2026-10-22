---
license: apache-2.0
pipeline_tag: text-generation
tags:
- gguf
- quantized
base_model:
- RecursiveSI/flint
---

# Flint

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Flint-GGUF
```

### Source models
- https://huggingface.co/RecursiveSI/flint

### Notes
- Ships `BF16`, `Q8_0` and `Q4_K_M`.
- 39.8B MoE (~2.5B active), 49 layers (2 dense + 47 MoE), 256 routed experts with 6 active per token plus a shared expert, 262K context.
- In `Q4_K_M` the small non-expert tensors (embeddings, attention, shared expert) are kept at Q8_0.
- Text-only source: no mmproj, MTP or DFlash sidecars.
- Requires a llama.cpp build with Flint support: https://github.com/ggml-org/llama.cpp/pull/30928

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

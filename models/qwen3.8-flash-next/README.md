---
license: other
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- Qwen/Qwen3.8-Flash-Next
---

# Qwen3.8-Flash-Next

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Qwen3.8-Flash-Next-GGUF
```

### Source models
- https://huggingface.co/Qwen/Qwen3.8-Flash-Next
- https://huggingface.co/incoai/Qwen3.8-Flash-Next-DFlash2

### Notes
- `Q8_0` and `IQ4_NL`: all routed experts use the base quantization type.
- `Q2_K`: routed gate/up experts at Q2_K, routed down experts at IQ4_NL.
- Small non-expert tensors (embeddings, PLE embeddings, attention, shared experts) are kept at Q8_0, the PLE embedding is at Q4_0.
- Includes a Q8_0 mmproj for the vision encoder, MTP sidecars (Q8_0 / Q4_0) and a DFlash2 draft sidecar (BF16 / Q8_0 / Q4_0) for speculative decoding.
- The `Q2_K` routed gate/up expert tensors are calibrated with the imatrix from https://huggingface.co/AesSedai/Qwen3.8-Flash-Next-GGUF

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

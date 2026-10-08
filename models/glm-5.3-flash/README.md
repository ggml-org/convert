---
license: other
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- zai-org/GLM-5.3-Flash-BF16
---

# GLM-5.3-Flash

Run with https://llama.app

```bash
llama serve -hf __owner__/GLM-5.3-Flash-GGUF
```

### Source models
- https://huggingface.co/zai-org/GLM-5.3-Flash-BF16

### Notes
- 320B MoE (18B active), 288 routed + 1 shared expert per layer, mHC + DSA, 1 MTP layer.
- `Q4_K`: all routed experts at Q4_K.
- `Q2_K`: routed down experts at Q4_K, gate/up experts at Q2_K.
- `Q2_K_S`: all routed experts at Q2_K (smallest).
- Small non-expert tensors (embeddings, attention, shared experts, dense FFN) are kept at Q8_0.
- Includes a Q8_0 mmproj for the vision encoder and MTP sidecars (Q8_0 / Q4_0) for speculative decoding.
- The Q2_K / Q2_K_S expert tensors are calibrated with the imatrix from https://huggingface.co/AesSedai/GLM-5.3-Flash-GGUF

### TODOs
- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

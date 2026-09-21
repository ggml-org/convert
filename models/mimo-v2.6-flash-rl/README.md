---
license: mit
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- XiaomiMiMo/MiMo-V2.6-Flash-RL
---

# MiMo-V2.6-Flash-RL

Run with https://llama.app

```bash
llama serve -hf __owner__/MiMo-V2.6-Flash-RL-GGUF
```

### Source models
- https://huggingface.co/XiaomiMiMo/MiMo-V2.6-Flash-RL

### Notes
- The MXFP4 output keeps the routed experts at their native MXFP4 precision.
- The Q2_K output keeps the expert down projections at MXFP4, and quantizes the gate/up projections to Q2_K.
- Includes MTP sidecars (MXFP4 and Q8_0) for speculative decoding (`--mtp`).
- Includes a Q8_0 mmproj for the vision and audio encoders.
- Currently, the Q2 models do not use an imatrix calibration due to lack of one.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

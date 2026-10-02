---
license: mit
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- XiaomiMiMo/MiMo-V2.6-Pro-MOPD
---

# MiMo-V2.6-Pro-MOPD

Run with https://llama.app

```bash
llama serve -hf __owner__/MiMo-V2.6-Pro-MOPD-GGUF
```

### Source models
- https://huggingface.co/XiaomiMiMo/MiMo-V2.6-Pro-MOPD

### Notes
- The MXFP4 output keeps the routed experts at their native MXFP4 precision.
- The Q2_K output keeps the expert down projections at MXFP4, and quantizes the gate/up projections to Q2_K.
- Includes MTP sidecars (Q4_0 and Q8_0) for speculative decoding (`--mtp`).
- Includes a DFlash drafter sidecar (BF16 and Q8_0) for speculative decoding, converted from the `dflash/` subdirectory of the source repo.
- Includes a Q8_0 mmproj for the vision and audio encoders.
- The Q2_K expert gate/up tensors are calibrated with the imatrix from https://huggingface.co/AesSedai/MiMo-V2.6-Pro-MOPD-GGUF

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

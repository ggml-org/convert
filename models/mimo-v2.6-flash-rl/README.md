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
- Includes a Q8_0 mmproj for the vision and audio encoders.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

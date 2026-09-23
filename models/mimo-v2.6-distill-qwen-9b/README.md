---
license: mit
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- XiaomiMiMo/MiMo-V2.6-Distill-Qwen-9B
---

# MiMo-V2.6-Distill-Qwen-9B

Run with https://llama.app

```bash
llama serve -hf __owner__/MiMo-V2.6-Distill-Qwen-9B-GGUF
```

### Source models
- https://huggingface.co/XiaomiMiMo/MiMo-V2.6-Distill-Qwen-9B

### Notes
- Includes a Q8_0 mmproj for the vision encoder.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

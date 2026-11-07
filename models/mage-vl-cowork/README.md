---
license: apache-2.0
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- microsoft/Mage-VL-Cowork
---

# Mage-VL-Cowork

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Mage-VL-Cowork-GGUF
```

### Source models
- https://huggingface.co/microsoft/Mage-VL-Cowork

### Notes
- Requires a llama.cpp build that includes https://github.com/ggml-org/llama.cpp/pull/31819

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

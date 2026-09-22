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
- TODO: remove the chat template patch from convert.sh once the upstream template is fixed (interim fix: https://gist.github.com/coder543/d8f56cd6db67de4cafbb5bdb6c2dfb4d).

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

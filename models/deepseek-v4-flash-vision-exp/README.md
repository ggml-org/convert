---
license: mit
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- deepseek-ai/DeepSeek-V4-Flash-Vision-Exp
---

# DeepSeek-V4-Flash-Vision-Exp

Run with https://llama.app

```bash
llama serve -hf __owner__/DeepSeek-V4-Flash-Vision-Exp-GGUF
```

### Source models
- https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-Vision-Exp

### Notes
- Includes a Q8_0 mmproj for the vision encoder.
- Currently, the Q2 models do not use an imatrix calibration due to lack of one.

### TODOs
- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

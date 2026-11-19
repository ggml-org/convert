---
license: other
license_name: lfm1.0
license_link: https://huggingface.co/LiquidAI/LFM3-1.7B/blob/main/LICENSE
pipeline_tag: text-generation
tags:
- gguf
- quantized
base_model:
- LiquidAI/LFM3-1.7B
---

# LFM3-1.7B

Run with https://llama.app

```bash
llama serve -hf __owner__/LFM3-1.7B-GGUF
```

### Source models
- https://huggingface.co/LiquidAI/LFM3-1.7B

### Notes
- Q8_0 and Q4_K_M use the same quantization as LiquidAI's own GGUFs: https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF
- For a smaller build, LiquidAI also publishes a Quantization-Aware Distillation (QAD) Q4_0, trained to recover the accuracy lost to Q4_0 quantization.
- Requires a llama.cpp build with LFM3 support: https://github.com/ggml-org/llama.cpp/pull/31252

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

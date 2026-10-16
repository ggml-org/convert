---
license: other
license_name: lfm1.0
license_link: https://huggingface.co/LiquidAI/LFM2.5-24B-A2B/blob/main/LICENSE
pipeline_tag: text-generation
tags:
- gguf
- quantized
base_model:
- LiquidAI/LFM2.5-24B-A2B
---

# LFM2.5-24B-A2B

Run with https://llama.app

```bash
llama serve -hf __owner__/LFM2.5-24B-A2B-GGUF
```

### Source models
- https://huggingface.co/LiquidAI/LFM2.5-24B-A2B

### Notes
- Q8_0 and Q4_K_M use the same quantization as LiquidAI's own GGUFs: https://huggingface.co/LiquidAI/LFM2.5-24B-A2B-GGUF
- For a smaller build, LiquidAI also publishes a Quantization-Aware Distillation (QAD) Q4_0, trained to recover the accuracy lost to Q4_0 quantization.

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

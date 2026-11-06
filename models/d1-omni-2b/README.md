---
license: other
license_name: lfm1.0
license_link: https://huggingface.co/LiquidAI/d1-Omni-2B/blob/main/LICENSE
pipeline_tag: audio-text-to-text
tags:
- gguf
- quantized
- decision-model
base_model:
- LiquidAI/d1-Omni-2B
---

# d1-Omni-2B

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/d1-Omni-2B-GGUF -b 8192 -ub 8192
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/31275

### Source models
- https://huggingface.co/LiquidAI/d1-Omni-2B

### Notes
- Takes text, image, audio and video input (video needs `ffmpeg` on `PATH`).
- A question is read in one batch, so `-b` and `-ub` must hold its state and media. At the default `-ub 512`, longer inputs are rejected and images get a smaller token budget, which changes the answers.
- The mmproj holds the vision encoder and the audio encoder.
- BF16 and Q8_0 have the same tensors as LiquidAI's own GGUFs: https://huggingface.co/LiquidAI/d1-Omni-2B-GGUF
- Requires llama.cpp `b11960` or newer.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

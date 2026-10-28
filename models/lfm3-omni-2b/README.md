---
license: other
license_name: lfm1.0
license_link: https://huggingface.co/LiquidAI/LFM3-Omni-2B/blob/main/LICENSE
pipeline_tag: any-to-any
tags:
- gguf
- quantized
base_model:
- LiquidAI/LFM3-Omni-2B
---

# LFM3-Omni-2B

Run with https://llama.app

```bash
llama serve -hf __owner__/LFM3-Omni-2B-GGUF
```

### Source models
- https://huggingface.co/LiquidAI/LFM3-Omni-2B

### Notes
- Takes text, image, audio and video input (video needs `ffmpeg` on `PATH`); speech output goes through the server's `/tts` endpoint.
- The mmproj holds the vision encoder, the audio encoder, and the audio output path (depthformer + codec).
- Q8_0 and Q4_K_M use the same quantization as LiquidAI's own GGUFs: https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF
- Requires a llama.cpp build with LFM3-Omni support: https://github.com/ggml-org/llama.cpp/pull/31257

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

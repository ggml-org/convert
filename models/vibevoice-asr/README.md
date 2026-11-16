---
license: mit
pipeline_tag: automatic-speech-recognition
tags:
- gguf
- quantized
base_model:
- microsoft/VibeVoice-ASR-HF
---

# VibeVoice-ASR

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/VibeVoice-ASR-GGUF
```

### Source models
- https://huggingface.co/microsoft/VibeVoice-ASR-HF

### Notes
- This is a speech-to-text model. See https://github.com/ggml-org/llama.cpp/pull/32329

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

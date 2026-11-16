---
license: apache-2.0
pipeline_tag: automatic-speech-recognition
tags:
- gguf
- quantized
base_model:
- bosonai/higgs-audio-v3-stt
---

# higgs-audio-v3-stt

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/higgs-audio-v3-stt-GGUF
```

### Source models
- https://huggingface.co/bosonai/higgs-audio-v3-stt

### Notes
- This is a speech-to-text model. See https://github.com/ggml-org/llama.cpp/pull/32329

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

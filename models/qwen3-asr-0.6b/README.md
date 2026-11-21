---
license: apache-2.0
pipeline_tag: automatic-speech-recognition
tags:
- gguf
- quantized
base_model:
- Qwen/Qwen3-ASR-0.6B
---

# Qwen3-ASR-0.6B

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Qwen3-ASR-0.6B-GGUF
```

### Source models
- https://huggingface.co/Qwen/Qwen3-ASR-0.6B

### Notes
- Speech recognition and language identification for 30 languages and 22 Chinese dialects.
- The model first outputs the detected language (`language English`), then the transcript. The chat template puts the language part in the reasoning (thinking) block, so the message content is only the transcript. Requires a llama.cpp build that includes https://github.com/ggml-org/llama.cpp/pull/32571

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

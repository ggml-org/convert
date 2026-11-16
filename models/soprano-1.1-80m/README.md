---
license: apache-2.0
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- ekwek/Soprano-1.1-80M
---

# Soprano-1.1-80M

Run it from the terminal:

```bash
llama-tts -hf __owner__/Soprano-1.1-80M-GGUF -p "Hello world" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/Soprano-1.1-80M-GGUF
```

### Source models
- https://huggingface.co/ekwek/Soprano-1.1-80M

### Notes
- English only, with a fixed voice. Supply normalized text (numbers spelled out).
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#soprano

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

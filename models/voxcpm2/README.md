---
license: apache-2.0
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- openbmb/VoxCPM2
---

# VoxCPM2

Run it from the terminal:

```bash
llama-tts -hf __owner__/VoxCPM2-GGUF -p "(A calm male narrator)Hello world" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/VoxCPM2-GGUF
```

### Source models
- https://huggingface.co/openbmb/VoxCPM2

### Notes
- Multilingual, the language is the one of the text. A voice description in parentheses at the start of the text designs the voice, e.g. `(A young woman, gentle and warm)Hello!`
- Voice cloning: `--tts-speaker-file` with a reference clip, no transcript needed.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#voxcpm2

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

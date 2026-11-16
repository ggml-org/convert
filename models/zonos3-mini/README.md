---
license: apache-2.0
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- Zyphra/ZONOS3-Mini
---

# ZONOS3-Mini

Run it from the terminal:

```bash
llama-tts -hf __owner__/ZONOS3-Mini-GGUF -p "Hello world" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/ZONOS3-Mini-GGUF
```

### Source models
- https://huggingface.co/Zyphra/ZONOS3-Mini

### Notes
- `--tts-voice` picks one of the predefined voices, `--tts-speaker-file` clones a reference voice (wav, mp3).
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#zonos3

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

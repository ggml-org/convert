---
license: mit
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- ResembleAI/chatterbox-turbo
---

# chatterbox-turbo

Run it from the terminal:

```bash
llama-tts -hf __owner__/chatterbox-turbo-GGUF -p "Hello world" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/chatterbox-turbo-GGUF
```

### Source models
- https://huggingface.co/ResembleAI/chatterbox-turbo

### Notes
- This is the English-only variant, `--tts-lang` is not used.
- `--tts-speaker-file` clones a reference voice (wav, mp3), the voice shipped with the model is used without it.
- See https://github.com/ggml-org/llama.cpp/blob/master/tools/tts/README.md#chatterbox

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

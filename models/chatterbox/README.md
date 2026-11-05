---
license: mit
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- ResembleAI/chatterbox
---

# chatterbox

Run it from the terminal:

```bash
llama-tts -hf __owner__/chatterbox-GGUF -p "Hello world" --tts-lang en --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/chatterbox-GGUF
```

### Source models
- https://huggingface.co/ResembleAI/chatterbox

### Notes
- This is Chatterbox Multilingual V3 (23 languages), `--tts-lang` selects the language.
- `--tts-speaker-file` clones a reference voice (wav, mp3), the voice shipped with the model is used without it.
- Requires a llama.cpp build that includes https://github.com/ggml-org/llama.cpp/pull/31698
- See https://github.com/ggml-org/llama.cpp/blob/master/tools/tts/README.md#chatterbox

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

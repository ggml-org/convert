---
license: apache-2.0
pipeline_tag: text-to-speech
tags:
- gguf
base_model:
- hexgrad/Kokoro-82M
---

# Kokoro-82M

Run it from the terminal:

```bash
llama-tts -hf __owner__/Kokoro-82M-GGUF -p "Hello world" --tts-voice af_heart --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/Kokoro-82M-GGUF
```

### Source models
- https://huggingface.co/hexgrad/Kokoro-82M

### Notes
- `--tts-voice` selects one of the voices shipped with the model; its first letter is the language (`a` American English, `b` British English, `e` Spanish, `f` French, `h` Hindi, `i` Italian, `p` Brazilian Portuguese, `j` Japanese, `z` Mandarin).
- Text input is English only. For the other languages, the prompt must already be phonemes (e.g. from espeak-ng).
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#kokoro

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

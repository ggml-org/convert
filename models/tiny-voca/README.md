---
license: apache-2.0
pipeline_tag: text-to-speech
tags:
- gguf
base_model:
- n4ze3m/tiny-voca
---

# tiny-voca

Run it from the terminal:

```bash
llama-tts -hf __owner__/tiny-voca-GGUF -p "Hello world" --tts-voice F2 --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/tiny-voca-GGUF
```

### Source models
- https://huggingface.co/n4ze3m/tiny-voca

### Notes
- English only, a 4.5M-parameter model. `--tts-voice` can be `M2` (default) or `F2`.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#tiny-voca

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

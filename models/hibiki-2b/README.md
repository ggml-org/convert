---
license: cc-by-4.0
pipeline_tag: audio-to-audio
tags:
- gguf
- quantized
base_model:
- kyutai/hibiki-2b-pytorch-bf16
---

# hibiki-2b

Run it with the server:

```bash
llama-server -hf __owner__/hibiki-2b-GGUF -c 1500
```

### Source models
- https://huggingface.co/kyutai/hibiki-2b-pytorch-bf16

### Notes
- Real-time speech translation, French speech in, English speech out.
- This is a full-duplex model: it only runs through the realtime endpoint of `llama-server` (audio in and out every 80 ms), not `llama-tts` or `/tts`. See https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md#full-duplex
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#hibiki

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

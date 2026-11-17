---
license: cc-by-nc-4.0
pipeline_tag: text-to-audio
tags:
- gguf
- quantized
base_model:
- m-a-p/YuE2-3B
---

# YuE2-3B

Run it from the terminal:

```bash
llama-tts -hf __owner__/YuE2-3B-GGUF -f song.txt --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/YuE2-3B-GGUF
```

### Source models
- https://huggingface.co/m-a-p/YuE2-3B
- https://huggingface.co/m-a-p/YuE2-Vae

### Notes
- Generates songs (vocals and accompaniment) as 48 kHz stereo. The prompt has a `[Tags]` section with the style and a `[Lyrics]` section.
- The VAE decoder comes from https://huggingface.co/m-a-p/YuE2-Vae and is stored in the mmproj.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#yue2

> [!NOTE]
> The weights are released under CC BY-NC 4.0 (non-commercial use only).

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

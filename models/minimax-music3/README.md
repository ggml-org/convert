---
license: other
license_name: minimax-music3-community-license
license_link: https://huggingface.co/MiniMaxAI/MiniMax-Music3/blob/main/LICENSE
pipeline_tag: text-to-audio
tags:
- gguf
- quantized
base_model:
- MiniMaxAI/MiniMax-Music3
---

# MiniMax-Music3

Run it from the terminal:

```bash
llama-tts -hf __owner__/MiniMax-Music3-GGUF -f song.txt --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/MiniMax-Music3-GGUF
```

### Source models
- https://huggingface.co/MiniMaxAI/MiniMax-Music3

### Notes
- Generates songs (vocals and accompaniment) as 44.1 kHz stereo. The prompt has a `[Tags]` section with the music description and a `[Lyrics]` section.
- Songs longer than about 3 minutes need a larger context, e.g. `-c 20480`.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#minimax-music-3

> [!NOTE]
> The weights are released under the MiniMax-Music3 Community License, see the license.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

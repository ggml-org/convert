---
license: other
license_name: fish-audio-research-license
license_link: https://huggingface.co/fishaudio/s2-pro/blob/main/LICENSE.md
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- fishaudio/s2-pro
---

# s2-pro

Run it from the terminal:

```bash
llama-tts -hf __owner__/s2-pro-GGUF -p "<|speaker:0|>Hello world [laughing]" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/s2-pro-GGUF
```

### Source models
- https://huggingface.co/fishaudio/s2-pro

### Notes
- Speaker tags `<|speaker:0|>`, `<|speaker:1|>`, ... give each character its own voice, inline instructions such as `[laughing]` or `[whisper]` control the delivery.
- Voice cloning: `--tts-speaker-file` with a reference clip, optionally `--tts-speaker-text` with its transcript.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#fish-audio-s2-pro

> [!NOTE]
> The weights are released under the Fish Audio Research License: free for research and non-commercial use, commercial use is limited, see the license.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

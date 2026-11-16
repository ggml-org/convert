---
license: other
license_name: fish-audio-research-license
license_link: https://huggingface.co/fishaudio/drama-3/blob/main/LICENSE
pipeline_tag: text-to-speech
tags:
- gguf
- quantized
base_model:
- fishaudio/drama-3
---

# drama-3

Run it from the terminal:

```bash
llama-tts -hf __owner__/drama-3-GGUF -p "<|speaker:0|> Hello world" --output out.wav
```

Or with the server, using the `/tts` endpoint:

```bash
llama serve -hf __owner__/drama-3-GGUF
```

### Source models
- https://huggingface.co/fishaudio/drama-3

### Notes
- Speaker tags `<|speaker:0|>` to `<|speaker:15|>` give each character its own voice. Voice cloning is not supported yet.
- See https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal/tts.md#drama-3

> [!NOTE]
> The weights are released under the Fish Audio Community License: free for research and non-commercial use, commercial use is limited, see the license.

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

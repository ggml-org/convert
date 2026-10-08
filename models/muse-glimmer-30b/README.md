---
license: apache-2.0
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- meta-models/Muse-Glimmer-30B
---

# Muse-Glimmer-30B

Run with https://llama.app

```bash
llama serve -hf __owner__/Muse-Glimmer-30B-GGUF
```

### Source models
- https://huggingface.co/meta-models/Muse-Glimmer-30B
- https://huggingface.co/meta-models/Muse-Glimmer-30B-assistant

### Notes
- Includes a Q8_0 mmproj for the vision encoder.
- Includes a DFlash drafter sidecar (BF16, Q8_0 and Q4_0) for speculative decoding.

### TODOs

- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

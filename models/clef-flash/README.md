---
license: apache-2.0
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
- decision-model
base_model:
- Cloudflare/clef-flash
---

# Clef-Flash

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Clef-Flash-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. Requires https://github.com/ggml-org/llama.cpp/pull/29831

### Source models
- https://huggingface.co/Cloudflare/clef-flash

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

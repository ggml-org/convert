---
license: apache-2.0
pipeline_tag: zero-shot-classification
tags:
- gguf
- quantized
- decision-model
base_model:
- Cloudflare/clef
---

# Clef

Run with https://llama.app

```bash
llama serve -hf __owner__/Clef-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. Requires https://github.com/ggml-org/llama.cpp/pull/29831

### Source models
- https://huggingface.co/Cloudflare/clef

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

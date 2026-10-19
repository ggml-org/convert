---
license: cc-by-nc-4.0
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
- decision-model
base_model:
- openjev/openjev
---

# OpenJev

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/OpenJev-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/29818

### Source models
- https://huggingface.co/openjev/openjev

> [!NOTE]
> The weights are released under CC BY-NC 4.0 (non-commercial use only).

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

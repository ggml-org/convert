---
license: apache-2.0
pipeline_tag: text-classification
tags:
- gguf
- quantized
- decision-model
base_model:
- convaiinnovations/laya
---

# Laya

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Laya-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/29818

### Source models
- https://huggingface.co/convaiinnovations/laya

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

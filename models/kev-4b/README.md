---
license: apache-2.0
pipeline_tag: text-classification
tags:
- gguf
- quantized
- decision-model
base_model:
- jaredpalmer/kev-4b
---

# Kev-4B

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Kev-4B-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/29818

### Source models
- https://huggingface.co/jaredpalmer/kev-4b
- https://huggingface.co/Qwen/Qwen3.5-4B-Base

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

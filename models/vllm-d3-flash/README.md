---
license: apache-2.0
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
- decision-model
base_model:
- vllm-sr/d3-flash
---

# vllm-d3-flash

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/vllm-d3-flash-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/30383

### Source models
- https://huggingface.co/vllm-sr/d3-flash

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

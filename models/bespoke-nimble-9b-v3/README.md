---
license: cc-by-nc-4.0
pipeline_tag: zero-shot-classification
tags:
- gguf
- quantized
- decision-model
base_model:
- bespokelabs/Bespoke-Nimble-9B-v3
---

# Bespoke-Nimble-9B-v3

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/Bespoke-Nimble-9B-v3-GGUF
```

This is a decision model, to be used via `/v1/systemone` API. See https://github.com/ggml-org/llama.cpp/pull/29818

### Source models
- https://huggingface.co/bespokelabs/Bespoke-Nimble-9B-v3
- https://huggingface.co/Qwen/Qwen3.5-9B

> [!NOTE]
> The weights are released under CC BY-NC 4.0 (non-commercial use only).

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

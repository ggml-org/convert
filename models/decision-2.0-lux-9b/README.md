---
license: apache-2.0
pipeline_tag: zero-shot-classification
tags:
- gguf
- quantized
- decision-model
base_model:
- vllm-sr/Decision-2.0-Lux-9B
---

# Decision-2.0-Lux-9B

Run with the [Decision 2.0 llama.cpp branch](https://github.com/Xunzhuo/llama.cpp/tree/decision2-gguf):

```bash
llama-server -hf __owner__/Decision-2.0-Lux-9B-GGUF:Q8_0 --embeddings --pooling none -c 8192 -b 8192 -ub 8192 -np 1
```

This is a decision model, to be used via the `/v1/systemone` API. Requires [Decision 2.0 runtime support](https://github.com/Xunzhuo/llama.cpp/tree/decision2-gguf).

Available in BF16, Q8_0 and Q4_K_M.

### Source models

- https://huggingface.co/vllm-sr/Decision-2.0-Lux-9B

> [!NOTE]
> Conversion recipes: [Decision 2.0 GGUF](https://github.com/Xunzhuo/convert/tree/decision2-gguf/models).

---
license: mit
pipeline_tag: image-text-to-text
tags:
- gguf
- quantized
base_model:
- deepseek-ai/DeepSeek-V4.1-Flash-1017
---

# DeepSeek-V4.1-Flash-1017

Run it in the Llama app: https://llama.app

Or from the terminal:

```bash
llama serve -hf __owner__/DeepSeek-V4.1-Flash-1017-GGUF
```

### Source models
- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017

### Notes
- Includes a Q8_0 mmproj for the vision encoder.
- The Q2_K quantization keeps the routed down experts in MXFP4.
- The Q2_K_S quantization converts the routed down experts to Q2_K.
- The Engram KV tensors are Q8_0 and the PLE table is IQ4_NL.
- The chat template is taken from https://huggingface.co/ISTA-DASLab/DeepSeek-V4.1-Flash-1017-GSQ-RCO-GGUF because the source repo does not provide one.
- The Q2 models do not use an imatrix calibration.

### TODOs
- add info

> [!IMPORTANT]
> This model is automatically converted using https://github.com/ggml-org/convert

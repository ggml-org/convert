# convert

[![Model Conversion](https://github.com/ggml-org/convert/actions/workflows/main.yml/badge.svg)](https://github.com/ggml-org/convert/actions/workflows/main.yml)

Automated pipeline for converting models to GGUF format and uploading them to HF.

Supported models: [models/](models/)

## Usage

```bash
# Convert all models
HF_TOKEN=xxx bash convert.sh --owner <org>

# Convert a single model
HF_TOKEN=xxx bash convert.sh --owner <org> --one gemma-4-12b

# Convert models matching a filter
HF_TOKEN=xxx bash convert.sh --owner <org> --filter '^gemma'
```

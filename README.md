# convert

[![Model Conversion](https://github.com/ggml-org/convert/actions/workflows/main.yml/badge.svg)](https://github.com/ggml-org/convert/actions/workflows/main.yml)

Automated pipeline for converting models to GGUF format and uploading them to HF.

Supported models: [models/](models/)

Sample models converted with this pipeline:

- https://huggingface.co/ggml-org/gemma-4-31B-it-GGUF
- https://huggingface.co/ggml-org/Qwen3.6-35B-A3B-GGUF
- https://huggingface.co/ggml-org/gpt-oss-20b-GGUF

## Usage

Requires `HF_TOKEN` with write permission to the target org.

```bash
# Convert all models
bash convert.sh --owner <org>

# Convert a single model
bash convert.sh --owner <org> --one gemma-4-12b

# Convert models matching a filter
bash convert.sh --owner <org> --filter '^gemma'

# Force re-convert (ignore SHA checks)
bash convert.sh --owner <org> --force

# Run via HF Jobs (cloud infrastructure)
bash hf-job.sh --owner <org>

# Run via HF Jobs with a custom hardware flavor
bash hf-job.sh --owner <org> --hardware cpu-basic
```

## Notes

- Models are converted only if at least one of the source models has been updated
- The README.md files are always updated, regardless if the source models have been updated
- All models in [ggml-org](https://huggingface.co/ggml-org) are auto-converted by a [GitHub Actions workflow](https://github.com/ggml-org/convert/actions/workflows/main.yml) once per week
  
  ```bash
  HF_TOKEN=xxx bash hf-job.sh --owner ggml-org
  ```

- A maintainer from the [ggml-org/hf](https://github.com/orgs/ggml-org/teams/hf) team can start the workflow manually from the [Actions pane](https://github.com/ggml-org/convert/actions/workflows/main.yml)
- The conversion uses the latest version of [llama.cpp](https://github.com/ggml-org/llama.cpp)

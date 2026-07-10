#!/bin/bash
set -euo pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"
MODE="${3:-full}"
MODEL_SRC="Qwen/Qwen3-0.6B"
DISPLAY_NAME="Qwen3-0.6B"
MODEL_TEMP="./model-temp-${DISPLAY_NAME//-/_}"

mkdir -p "$OUTPUT_DIR"

cat > "$OUTPUT_DIR/README.md" << MODELCARD
---
license: other
tags:
- gguf
- quantized
base_model:
- $MODEL_SRC
---

TODO: add info

MODELCARD

if [ "$MODE" = "readme-only" ]; then
  exit 0
fi

hf download "$MODEL_SRC" --local-dir "$MODEL_TEMP"
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$MODEL_TEMP" --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --outtype bf16
"$LLAMA_CPP/build/bin/llama-quantize" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
rm -rf "$MODEL_TEMP"

echo "${DISPLAY_NAME}-BF16.gguf"
echo "${DISPLAY_NAME}-Q8_0.gguf"

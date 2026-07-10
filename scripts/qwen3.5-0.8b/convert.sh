#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$1"
LLAMA_CPP="$2"
MODEL_SRC="Qwen/Qwen3.5-0.8B"
DISPLAY_NAME="Qwen3.5-0.8B"
MODEL_TEMP="./model-temp-${DISPLAY_NAME//-/_}"

mkdir -p "$OUTPUT_DIR"
cp "$SCRIPT_DIR/README.md" "$OUTPUT_DIR/"

hf download "$MODEL_SRC" --local-dir "$MODEL_TEMP"
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$MODEL_TEMP" --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --outtype bf16
"$LLAMA_CPP/build/bin/llama-quantize" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
rm -rf "$MODEL_TEMP"

echo "${DISPLAY_NAME}-BF16.gguf"
echo "${DISPLAY_NAME}-Q8_0.gguf"

#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="Qwen3-8B"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# DFlash draft
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH" \
    --outtype bf16 --target-model "$PATH_PRIMARY" \
    --outfile "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# DSpark sidecar
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DSPARK" \
    --outtype bf16 --target-model "$PATH_PRIMARY" \
    --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Main: Q8_0
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# DFlash: Q8_0
"$QUANTIZE" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# DSpark: Q8_0
"$QUANTIZE" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"

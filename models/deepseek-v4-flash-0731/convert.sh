#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="DeepSeek-V4-Flash-0731"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# DSpark sidecar: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" --dspark --target-model-dir "$PATH_PRIMARY" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Main model: MXFP4_MOE
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# DSpark sidecar: MXFP4
"$QUANTIZE" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"

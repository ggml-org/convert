#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="Soprano-1.1-80M"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: tiny, upstream converts it to F32
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f32 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-F32.gguf" --model-name "$DISPLAY_NAME"

# mmproj: the audio decoder (decoder.pth)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-F16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-F32.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-F32.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf"       >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-F16.gguf" >> "$OUTPUT_DIR/.produced_files"

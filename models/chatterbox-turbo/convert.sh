#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="chatterbox-turbo"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: the turbo talker, detected from t3_turbo_v1.safetensors
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# mmproj: s3gen, the voice and conditioning encoders, and the conds.pt voice
# The converter forces every tensor to F16 or F32, so --outtype only changes the file_type header
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-F16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf"       >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf"       >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-F16.gguf" >> "$OUTPUT_DIR/.produced_files"

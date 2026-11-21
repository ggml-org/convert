#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="VoxCPM2"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model (MiniCPM4 backbone, one hidden state per frame)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# mmproj: LocEnc, LocDiT and the residual LM layers (BF16), AudioVAE from audiovae.pth (always F32)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-BF16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"

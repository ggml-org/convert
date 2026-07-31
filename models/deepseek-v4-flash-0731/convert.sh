#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="DeepSeek-V4-Flash-0731"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
# TODO: re-enable MTP sidecar conversion
#python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
#    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# TODO: re-enable MTP sidecar conversion
# # MTP sidecar: BF16
# python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
#     --outtype bf16 --outfile "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" --mtp --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Main model: MXFP4_MOE
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# TODO: re-enable MTP sidecar quantization
# # MTP sidecar: Q8_0, Q4_0
# "$QUANTIZE"        "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
# "$QUANTIZE" --pure "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"
# TODO: re-enable MTP sidecar files
# echo "mtp-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
# echo "mtp-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
# echo "mtp-${DISPLAY_NAME}-Q4_0.gguf" >> "$OUTPUT_DIR/.produced_files"

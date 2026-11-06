#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="d1-Omni-2B"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# mmproj: vision encoder and audio encoder -- d1 only decides, so unlike LFM3-Omni there is no audio output path
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-BF16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Stock recipe, no overrides -- it matches the tensors of LiquidAI's own GGUFs
# ref: https://huggingface.co/LiquidAI/d1-Omni-2B-GGUF
# No Q4_K_M: LiquidAI ships BF16 and Q8_0 only, and its probabilities haven't been checked for accuracy
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"

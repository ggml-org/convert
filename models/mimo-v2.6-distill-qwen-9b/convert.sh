#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="MiMo-V2.6-Distill-Qwen-9B"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# Replace the buggy upstream chat template before converting.
# ref: https://gist.github.com/coder543/d8f56cd6db67de4cafbb5bdb6c2dfb4d
curl -fsSL "https://gist.githubusercontent.com/coder543/d8f56cd6db67de4cafbb5bdb6c2dfb4d/raw/mimo-v2.6-distill-chat-template.jinja" \
    -o "$PATH_PRIMARY/chat_template.jinja"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME" --no-mtp

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Main model: Q8_0
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-Q8_0.gguf"            >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf"     >> "$OUTPUT_DIR/.produced_files"

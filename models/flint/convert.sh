#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="Flint"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (text-only, no MTP layers)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# note: ^output.weight is anchored, otherwise it also matches attn_output.weight
FLAGS_Q4_K_M="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type shexp=q8_0 \
"

# Main model: Q8_0, Q4_K_M
"$QUANTIZE"               "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" $FLAGS_Q4_K_M "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q4_K_M.gguf" Q4_K_M 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q4_K_M.gguf" >> "$OUTPUT_DIR/.produced_files"

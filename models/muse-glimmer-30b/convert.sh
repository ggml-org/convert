#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="Muse-Glimmer-30B"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# mmproj
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-BF16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# DFlash drafter: requires the target model dir for tokenizer, hidden size and layer metadata
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH" \
    --outtype bf16 --target-model-dir "$PATH_PRIMARY" \
    --outfile "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# note: ^output.weight is anchored, otherwise it also matches attn_output.weight
FLAGS_Q4_K_M="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type attn_=q8_0 \
    "

# Main model: Q8_0, Q4_K_M
"$QUANTIZE"               "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" $FLAGS_Q4_K_M "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q4_K_M.gguf" Q4_K_M 1>&2

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# DFlash drafter: Q8_0, Q4_0
"$QUANTIZE"        "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" --pure "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q4_K_M.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q4_0.gguf" >> "$OUTPUT_DIR/.produced_files"

#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="NVIDIA-Nemotron-3.5-Lightning-30B-A3B"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model (no MTP layers)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# MTP layers
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" --mtp --model-name "$DISPLAY_NAME"

# DFlash
#python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH" \
#    --outtype bf16 --target-model "$PATH_PRIMARY" \
#    --outfile "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-NVFP4.gguf" --model-name "${DISPLAY_NAME}-DFlash"

# DSpark
#python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DSPARK" \
#    --target-model "$PATH_PRIMARY" \
#    --fp8-as-q8 \
#    --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-NVFP4.gguf" --model-name "${DISPLAY_NAME}-DSpark"

# NVFP4 model
#python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_NVFP4" \
#    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-NVFP4.gguf" --no-mtp --model-name "${DISPLAY_NAME}-NVFP4"

# --- Quantizations ---

FLAGS_Q4_0="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q6_k \
    --tensor-type shexp=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type ssm_=q8_0 \
    "

# Main model: Q8_0, Q4_0
"$QUANTIZE"               "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" $FLAGS_Q4_0 "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# MTP: Q8_0, Q4_0
"$QUANTIZE"        "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" --pure "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# --- Produced files ---

# Preserve the established repository name for the BF16 output.
echo "${DISPLAY_NAME}-BF16.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q4_0.gguf"        >> "$OUTPUT_DIR/.produced_files"
#echo "${DISPLAY_NAME}-NVFP4.gguf"      >> "$OUTPUT_DIR/.produced_files"

echo "mtp-${DISPLAY_NAME}-BF16.gguf"    >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q8_0.gguf"    >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q4_0.gguf"    >> "$OUTPUT_DIR/.produced_files"

#echo "dflash-${DISPLAY_NAME}-NVFP4.gguf" >> "$OUTPUT_DIR/.produced_files"
#echo "dspark-${DISPLAY_NAME}-NVFP4.gguf" >> "$OUTPUT_DIR/.produced_files"

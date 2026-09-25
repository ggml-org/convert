#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="MiMo-V2.6-Flash-RL"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" --no-tensor-first-split \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# MTP sidecar: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" --mtp --model-name "$DISPLAY_NAME"

# mmproj: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-BF16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# DFlash draft: BF16 (lives in the dflash/ subdirectory of the primary repo)
# note: shard discovery matches model*.safetensors before reading model.safetensors.index.json,
#       but upstream names it dflash_draft_model.safetensors - symlink to pass the prefix check
ln -sfn dflash_draft_model.safetensors "$PATH_PRIMARY/dflash/model.safetensors"
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY/dflash" \
    --outtype bf16 --target-model-dir "$PATH_PRIMARY" \
    --outfile "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

FLAGS_MXFP4=" \
"

# Main model: MXFP4_MOE
"$QUANTIZE" --keep-split $FLAGS_MXFP4 "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

FLAGS_Q2_K="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q6_k \
    --tensor-type attn_=q8_0 \
    --tensor-type ffn_down.weight=q8_0 \
    --tensor-type ffn_gate.weight=q8_0 \
    --tensor-type ffn_up.weight=q8_0 \
    --tensor-type ffn_down_exps=mxfp4 \
    --tensor-type ffn_gate_exps=q2_k \
    --tensor-type ffn_up_exps=q2_k \
"

# Main model: MXFP4_MOE + Q2_K overrides
"$QUANTIZE" --keep-split --allow-requantize $FLAGS_Q2_K "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K.gguf" MXFP4_MOE 1>&2

# MTP sidecar: Q4_0 + Q8_0
"$QUANTIZE" --pure "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2
"$QUANTIZE"        "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# DFlash draft: Q8_0
"$QUANTIZE" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-MXFP4-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-MXFP4-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00001-of-00002.gguf"  >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00002-of-00002.gguf"  >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-BF16.gguf"             >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q4_0.gguf"             >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q8_0.gguf"             >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-BF16.gguf"          >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf"          >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-BF16.gguf"          >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q8_0.gguf"          >> "$OUTPUT_DIR/.produced_files"

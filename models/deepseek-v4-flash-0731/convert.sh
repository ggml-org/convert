#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="DeepSeek-V4-Flash-0731"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" --no-tensor-first-split \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# DSpark sidecar: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" --dspark --target-model-dir "$PATH_PRIMARY" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

FLAGS_MXFP4="\
"

# Main model: MXFP4_MOE
"$QUANTIZE" --keep-split $FLAGS_MXFP4 "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

FLAGS_Q2_K="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type output.weight=q6_k \
    --tensor-type attn_=q8_0 \
    --tensor-type shexp=q8_0 \
    --tensor-type hc_attn=q8_0 \
    --tensor-type hc_ffn=q8_0 \
    --tensor-type indexer=q8_0 \
    --tensor-type output_hc=q8_0 \
    --tensor-type ffn_down_exps=mxfp4 \
    --tensor-type ffn_gate_exps=q2_k \
    --tensor-type ffn_up_exps=q2_k \
"

# Main model: MXFP4_MOE + Q2_K overrides
"$QUANTIZE" --keep-split --allow-requantize $FLAGS_Q2_K "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K.gguf" MXFP4_MOE 1>&2

FLAGS_Q2_K_S="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type output.weight=q6_k \
    --tensor-type attn_=q8_0 \
    --tensor-type shexp=q8_0 \
    --tensor-type hc_attn=q8_0 \
    --tensor-type hc_ffn=q8_0 \
    --tensor-type indexer=q8_0 \
    --tensor-type output_hc=q8_0 \
    --tensor-type ffn_down_exps=q2_k \
    --tensor-type ffn_gate_exps=q2_k \
    --tensor-type ffn_up_exps=q2_k \
"

# Main model: MXFP4_MOE + Q2_K_S overrides
"$QUANTIZE" --keep-split --allow-requantize $FLAGS_Q2_K_S "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K_S.gguf" MXFP4_MOE 1>&2

FLAGS_MXFP4="\
"

# DSpark sidecar: MXFP4
"$QUANTIZE" $FLAGS_MXFP4 "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-MXFP4-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-MXFP4-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K_S-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K_S-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"

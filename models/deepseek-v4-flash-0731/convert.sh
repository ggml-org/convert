#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="DeepSeek-V4-Flash-0731"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# DSpark sidecar: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" --dspark --target-model-dir "$PATH_PRIMARY" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

FLAGS_IQ2_S="--pure --tensor-type output.weight=q6_k --tensor-type attn_=q8_0 --tensor-type shexp=q8_0 --tensor-type ffn_down_exps=mxfp4 --tensor-type ffn_gate_exps=iq2_s --tensor-type ffn_up_exps=iq2_s"

# Main model: MXFP4_MOE
"$QUANTIZE" "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# Main model: MXFP4_MOE + IQ2_S overrides
"$QUANTIZE" $FLAGS_IQ2_S "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-IQ2_S.gguf" MXFP4_MOE 1>&2

# DSpark sidecar: MXFP4
"$QUANTIZE" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-IQ2_S.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"

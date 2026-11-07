#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="DeepSeek-V4.1-Flash-1017"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# The source repo has no Jinja chat template; embed the one from the ISTA-DASLab GGUF repo.
hf download "ISTA-DASLab/DeepSeek-V4.1-Flash-1017-GSQ-RCO-GGUF" chat_template.jinja --local-dir "$PATH_PRIMARY" 1>&2

# --- Conversions ---

# Main model: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" --no-tensor-first-split --split-max-size 100G \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# DSpark sidecar: BF16 (the mtp.* tensors of the same checkpoint)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" --dspark --target-model-dir "$PATH_PRIMARY" --model-name "$DISPLAY_NAME"

# mmproj: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-BF16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

FLAGS_Q2_K="--pure \
    --tensor-type per_layer_token_embd.weight=q4_0 \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q8_0 \
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
"$QUANTIZE" --keep-split --allow-requantize $FLAGS_Q2_K "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-"*.gguf "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K.gguf" MXFP4_MOE 1>&2

# DSpark sidecar: MXFP4
"$QUANTIZE" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dspark-${DISPLAY_NAME}-MXFP4.gguf" MXFP4_MOE 1>&2

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Produced files ---

for f in "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K-"*.gguf; do
    basename "$f" >> "$OUTPUT_DIR/.produced_files"
done
echo "dspark-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dspark-${DISPLAY_NAME}-MXFP4.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"

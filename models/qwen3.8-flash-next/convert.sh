#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

# qwen4exp is not in llama.cpp master yet, pin the PR head with --llama-commit
# ref: https://github.com/ggml-org/llama.cpp/pull/27742

DISPLAY_NAME="Qwen3.8-Flash-Next"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model (no MTP layers): BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" --no-tensor-first-split \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# MTP sidecar: BF16
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" --mtp --model-name "$DISPLAY_NAME"

# mmproj
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# DFlash draft: needs the target model dir for tokenizer and layer metadata
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH" \
    --outtype bf16 --target-model-dir "$PATH_PRIMARY" \
    --outfile "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Main model: Q8_0, per_layer_token_embd Q4_0
"$QUANTIZE" --keep-split --pure --tensor-type per_layer_token_embd.weight=q4_0 \
    "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2

FLAGS_IQ4_NL="--pure \
    --tensor-type per_layer_token_embd.weight=q4_0 \
    --tensor-type ^token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type ssm_=q8_0 \
    --tensor-type shexp=q8_0 \
"

# Main model: IQ4_NL, per_layer_token_embd Q4_0
"$QUANTIZE" --keep-split $FLAGS_IQ4_NL \
    "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-IQ4_NL.gguf" IQ4_NL 1>&2

# imatrix calibration for the Q2_K output
# note: single-file download, not a DEP_* - the upstream repo also ships >1TB of quants
hf download "AesSedai/Qwen3.8-Flash-Next-GGUF" imatrix.gguf --local-dir "$OUTPUT_DIR" 1>&2

# note: same overrides as IQ4_NL, the routed gate/up experts drop to Q2_K and use the imatrix,
#       while the routed down experts stay at IQ4_NL (imatrix is not applied to them)
FLAGS_Q2_K="$FLAGS_IQ4_NL \
    --imatrix $OUTPUT_DIR/imatrix.gguf \
    --include-weights ffn_gate_exps \
    --include-weights ffn_up_exps \
    --tensor-type ffn_down_exps=iq4_nl \
"

# Main model: Q2_K (routed gate/up experts at Q2_K, routed down experts at IQ4_NL)
"$QUANTIZE" --keep-split $FLAGS_Q2_K \
    "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K.gguf" Q2_K 1>&2

# MTP: Q8_0, Q4_0
"$QUANTIZE"        "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" --pure "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# DFlash: Q8_0, Q4_0
"$QUANTIZE"        "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" --pure "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/dflash-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-Q8_0-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q8_0-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-IQ4_NL-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-IQ4_NL-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q4_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-BF16.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "dflash-${DISPLAY_NAME}-Q4_0.gguf" >> "$OUTPUT_DIR/.produced_files"

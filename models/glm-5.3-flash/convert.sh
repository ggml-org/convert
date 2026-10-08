#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="GLM-5.3-Flash"
QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# --- Conversions ---

# Main model (no MTP layers): BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" --no-tensor-first-split \
    --outtype bf16 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-BF16.gguf" --no-mtp --model-name "$DISPLAY_NAME"

# MTP sidecar: BF16 (intermediate for quantization only)
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype bf16 --outfile "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" --mtp --model-name "$DISPLAY_NAME"

# mmproj: Q8_0
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype q8_0 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-Q8_0.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Quantizations ---

# Shared overrides: keep the small non-expert tensors at high precision.
# note: for glm5-next, llama.cpp auto-keeps hc_*, indexer.* (except the tiny k_norm),
#       ssm_*, and attn_kv_a_mqa/attn_k_b/attn_v_b in f16, so the routed experts are
#       the only tensors that follow the base type (Q4_K / Q2_K).
FLAGS_BASE="--pure \
    --tensor-type token_embd.weight=q8_0 \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type shexp=q8_0 \
    --tensor-type ffn_down.weight=q8_0 \
    --tensor-type ffn_gate.weight=q8_0 \
    --tensor-type ffn_up.weight=q8_0 \
    --tensor-type indexer=q8_0 \
"

# imatrix calibration for the low-bit outputs
# note: single-file download, not a DEP_* - the upstream repo also ships >1TB of quants
hf download "AesSedai/GLM-5.3-Flash-GGUF" imatrix.gguf --local-dir "$OUTPUT_DIR" 1>&2

# note: restrict the imatrix to the routed experts, everything else is already kept at Q8_0
FLAGS_IMATRIX="--imatrix $OUTPUT_DIR/imatrix.gguf \
    --include-weights ffn_gate_exps \
    --include-weights ffn_up_exps \
    --include-weights ffn_down_exps \
"

# Main model: Q4_K (all routed experts at Q4_K)
"$QUANTIZE" --keep-split $FLAGS_BASE "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q4_K.gguf" Q4_K 1>&2

# Main model: Q2_K (routed down experts at Q4_K, gate/up experts at Q2_K)
"$QUANTIZE" --keep-split $FLAGS_BASE $FLAGS_IMATRIX \
    --tensor-type ffn_down_exps=q4_k \
    "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K.gguf" Q2_K 1>&2

# Main model: Q2_K_S (all routed experts at Q2_K)
"$QUANTIZE" --keep-split $FLAGS_BASE $FLAGS_IMATRIX \
    --tensor-type ffn_down_exps=q2_k \
    --tensor-type ffn_gate_exps=q2_k \
    --tensor-type ffn_up_exps=q2_k \
    "$OUTPUT_DIR/${DISPLAY_NAME}-BF16-00001-of-00002.gguf" "$OUTPUT_DIR/${DISPLAY_NAME}-Q2_K_S.gguf" Q2_K 1>&2

# MTP sidecar: Q8_0, Q4_0
"$QUANTIZE"        "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q8_0.gguf" Q8_0 1>&2
"$QUANTIZE" --pure "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-BF16.gguf" "$OUTPUT_DIR/mtp-${DISPLAY_NAME}-Q4_0.gguf" Q4_0 1>&2

# --- Produced files ---

echo "${DISPLAY_NAME}-Q4_K-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q4_K-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K_S-00001-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "${DISPLAY_NAME}-Q2_K_S-00002-of-00002.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mtp-${DISPLAY_NAME}-Q4_0.gguf" >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-Q8_0.gguf" >> "$OUTPUT_DIR/.produced_files"

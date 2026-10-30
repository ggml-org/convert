#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

QUANTIZE="$LLAMA_CPP/build/bin/llama-quantize"

# Qwen3.5-4B target with its integrated MTP head.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_QWEN35_MTP" \
    --outtype bf16 --outfile "$OUTPUT_DIR/Qwen3.5-4B-MTP-BF16.gguf" \
    --model-name "Qwen3.5-4B-MTP"
"$QUANTIZE" --pure \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type ssm_=q8_0 \
    "$OUTPUT_DIR/Qwen3.5-4B-MTP-BF16.gguf" \
    "$OUTPUT_DIR/Qwen3.5-4B-MTP-Q4_K_M.gguf" Q4_K_M 1>&2

# Shared Qwen3-4B target for DFlash, DSpark, and EAGLE-3.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_QWEN3" \
    --outtype bf16 --outfile "$OUTPUT_DIR/Qwen3-4B-BF16.gguf" \
    --model-name "Qwen3-4B"
"$QUANTIZE" "$OUTPUT_DIR/Qwen3-4B-BF16.gguf" \
    "$OUTPUT_DIR/Qwen3-4B-Q4_K_M.gguf" Q4_K_M 1>&2

# DFlash.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH" \
    --outtype bf16 --target-model "$PATH_QWEN3" \
    --outfile "$OUTPUT_DIR/dflash-Qwen3-4B-BF16.gguf" \
    --model-name "Qwen3-4B-DFlash"
"$QUANTIZE" --pure "$OUTPUT_DIR/dflash-Qwen3-4B-BF16.gguf" \
    "$OUTPUT_DIR/dflash-Qwen3-4B-Q4_K_M.gguf" Q4_K_M 1>&2

# DSpark.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DSPARK" \
    --outtype bf16 --target-model "$PATH_QWEN3" \
    --outfile "$OUTPUT_DIR/dspark-Qwen3-4B-BF16.gguf" \
    --model-name "Qwen3-4B-DSpark"
"$QUANTIZE" --pure "$OUTPUT_DIR/dspark-Qwen3-4B-BF16.gguf" \
    "$OUTPUT_DIR/dspark-Qwen3-4B-Q4_K_M.gguf" Q4_K_M 1>&2

# EAGLE-3.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_EAGLE3" \
    --outtype bf16 --target-model "$PATH_QWEN3" \
    --outfile "$OUTPUT_DIR/eagle3-Qwen3-4B-BF16.gguf" \
    --model-name "Qwen3-4B-EAGLE3"
"$QUANTIZE" "$OUTPUT_DIR/eagle3-Qwen3-4B-BF16.gguf" \
    "$OUTPUT_DIR/eagle3-Qwen3-4B-Q8_0.gguf" Q8_0 1>&2

# Qwen3.8-27B target and DFlash2 draft.
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_QWEN38" \
    --outtype bf16 --no-mtp \
    --outfile "$OUTPUT_DIR/Qwen3.8-27B-BF16.gguf" \
    --model-name "Qwen3.8-27B"
"$QUANTIZE" --pure \
    --tensor-type ^output.weight=q8_0 \
    --tensor-type shexp=q8_0 \
    --tensor-type latent=q8_0 \
    --tensor-type attn_=q8_0 \
    --tensor-type ssm_=q8_0 \
    "$OUTPUT_DIR/Qwen3.8-27B-BF16.gguf" \
    "$OUTPUT_DIR/Qwen3.8-27B-Q4_K_M.gguf" Q4_K_M 1>&2

python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_DFLASH2" \
    --outtype bf16 --target-model "$PATH_QWEN38" \
    --outfile "$OUTPUT_DIR/dflash2-Qwen3.8-27B-BF16.gguf" \
    --model-name "Qwen3.8-27B-DFlash2"
"$QUANTIZE" "$OUTPUT_DIR/dflash2-Qwen3.8-27B-BF16.gguf" \
    "$OUTPUT_DIR/dflash2-Qwen3.8-27B-Q8_0.gguf" Q8_0 1>&2

# The Nemotron 24GB target and LiLiCorr draft are already published as official GGUFs.
cp "$PATH_NEMOTRON/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB.gguf" \
    "$OUTPUT_DIR/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB.gguf"
cp "$PATH_LILICORR/NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB-LiLiCorr.gguf" \
    "$OUTPUT_DIR/lilicorr-NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB-NVFP4.gguf"

cat >> "$OUTPUT_DIR/.produced_files" <<'EOF'
Qwen3.5-4B-MTP-Q4_K_M.gguf
Qwen3-4B-Q4_K_M.gguf
dflash-Qwen3-4B-Q4_K_M.gguf
dspark-Qwen3-4B-Q4_K_M.gguf
eagle3-Qwen3-4B-Q8_0.gguf
Qwen3.8-27B-Q4_K_M.gguf
dflash2-Qwen3.8-27B-Q8_0.gguf
NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB.gguf
lilicorr-NVIDIA-Nemotron-3.5-Bolt-74B-A9B-24GB-NVFP4.gguf
EOF

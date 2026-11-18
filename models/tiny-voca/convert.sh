#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="tiny-voca"

# the text-to-phonemes "tts" template tables come from dizione (with phonemizer/lexicon.tsv of the repo);
# without it the converter writes no template and the model only takes phonemes
python3 -m pip install git+https://github.com/n4ze3m/dizione

# --- Conversions ---

# Main model: phoneme encoder, 4.5M parameters, kept in F32
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f32 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-F32.gguf" --model-name "$DISPLAY_NAME"

# mmproj: duration predictor, frame transformers, synthesizer and the unknown-word model, kept in F32
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f32 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-F32.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Produced files ---

echo "${DISPLAY_NAME}-F32.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-F32.gguf" >> "$OUTPUT_DIR/.produced_files"

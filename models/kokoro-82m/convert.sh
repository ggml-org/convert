#!/bin/bash
set -euox pipefail

OUTPUT_DIR="$1"
LLAMA_CPP="$2"

DISPLAY_NAME="Kokoro-82M"

# the English text-to-phonemes "tts" template (pronunciation dictionary and POS tagger) comes from misaki and nltk;
# without them the converter writes no template and the model only takes phonemes
python3 -m pip install misaki nltk
python3 -m nltk.downloader averaged_perceptron_tagger_eng

# --- Conversions ---

# Main model: tiny, kept in F32
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f32 --outfile "$OUTPUT_DIR/${DISPLAY_NAME}-F32.gguf" --model-name "$DISPLAY_NAME"

# mmproj: decoder, vocoder and every voice in voices/
# The converter forces every tensor to F16 or F32, so --outtype only changes the file_type header
python3 "$LLAMA_CPP/convert_hf_to_gguf.py" "$PATH_PRIMARY" \
    --outtype f16 --outfile "$OUTPUT_DIR/mmproj-${DISPLAY_NAME}-F16.gguf" --mmproj --model-name "$DISPLAY_NAME"

# --- Produced files ---

echo "${DISPLAY_NAME}-F32.gguf"        >> "$OUTPUT_DIR/.produced_files"
echo "mmproj-${DISPLAY_NAME}-F16.gguf" >> "$OUTPUT_DIR/.produced_files"

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# To add a new model: append entries to each array (same index) + create a folder in scripts/
MODEL_SOURCES=(
  "Qwen/Qwen3-0.6B"
  "Qwen/Qwen3-0.6B-Base"
  "Qwen/Qwen3.5-0.8B"
  "Qwen/Qwen3.5-0.8B-Base"
)

MODEL_DISPLAY=(
  "Qwen3-0.6B"
  "Qwen3-0.6B-Base"
  "Qwen3.5-0.8B"
  "Qwen3.5-0.8B-Base"
)

MODEL_SCRIPTS=(
  "scripts/qwen3-0.6b/convert.sh"
  "scripts/qwen3-0.6b-base/convert.sh"
  "scripts/qwen3.5-0.8b/convert.sh"
  "scripts/qwen3.5-0.8b-base/convert.sh"
)

MODEL_READMES=(
  "scripts/qwen3-0.6b/README.md"
  "scripts/qwen3-0.6b-base/README.md"
  "scripts/qwen3.5-0.8b/README.md"
  "scripts/qwen3.5-0.8b-base/README.md"
)

MODEL_DESTINATIONS=(
  "ggerganov/Qwen3-0.6B-GGUF"
  "ggerganov/Qwen3-0.6B-Base-GGUF"
  "ggerganov/Qwen3.5-0.8B-GGUF"
  "ggerganov/Qwen3.5-0.8B-Base-GGUF"
)

if [ -z "${HF_TOKEN:-}" ]; then
  echo "Error: HF_TOKEN environment variable is not set"
  exit 1
fi

echo ">>> Preparing llama.cpp"
if [ -d "llama.cpp" ]; then
  echo ">>> llama.cpp already exists, pulling latest master"
  cd llama.cpp && git checkout master && git pull && cd ..
else
  git clone --depth 1 https://github.com/ggml-org/llama.cpp.git
fi

echo ">>> Building llama-quantize"
cd llama.cpp
mkdir -p build && cd build
cmake .. -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_UI=OFF
make -j$(nproc) llama-quantize
cd ../..

echo ">>> Installing llama.cpp Python dependencies"
pip install -r llama.cpp/requirements.txt

echo ">>> Installing HF CLI"
pip install -r requirements.txt

NUM_MODELS=${#MODEL_SOURCES[@]}

for (( i=0; i<NUM_MODELS; i++ )); do
  SRC="${MODEL_SOURCES[$i]}"
  DISPLAY="${MODEL_DISPLAY[$i]}"
  SCRIPT="${MODEL_SCRIPTS[$i]}"
  README="${MODEL_READMES[$i]}"
  DST="${MODEL_DESTINATIONS[$i]}"
  UPLOAD_DIR="./upload-${DISPLAY//-/_}"

  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo ">>> Processing: $SRC → $DST"
  echo "═══════════════════════════════════════════════════════════"

  echo ">>> Checking for updates in $SRC"
  CURRENT_SHA=$(python3 -c "import urllib.request, json, sys; print(json.load(urllib.request.urlopen('https://huggingface.co/api/models/' + sys.argv[1]))['sha'])" "$SRC")

  if [ -z "$CURRENT_SHA" ]; then
    echo "Error: Failed to retrieve model info from Hugging Face"
    exit 1
  fi

  echo ">>> Checking last processed SHA in $DST"
  LAST_SHA=$(curl -Ls "https://huggingface.co/$DST/resolve/main/.src_sha")

  if [ "$CURRENT_SHA" = "$LAST_SHA" ]; then
    echo ">>> Source model has not changed (SHA: $CURRENT_SHA). Uploading README only."
    mkdir -p "$UPLOAD_DIR"
    cp "$README" "$UPLOAD_DIR/"
    pip install -r requirements.txt
    hf repos create "$DST" --type model --exist-ok --token "$HF_TOKEN"
    hf upload "$DST" "$UPLOAD_DIR" --include "README.md" --type model --token "$HF_TOKEN"
    rm -rf "$UPLOAD_DIR"
    continue
  fi

  pip install -r llama.cpp/requirements.txt

  echo ">>> Running conversion script: $SCRIPT"
  PRODUCED_FILES=$(bash "$SCRIPT" "$UPLOAD_DIR" "./llama.cpp")

  echo ">>> Preparing upload for $DST"

  pip install -r requirements.txt

  echo "$CURRENT_SHA" > "$UPLOAD_DIR/.src_sha"

  hf repos create "$DST" --type model --exist-ok --token "$HF_TOKEN"

  GGUF_FLAGS=""
  while IFS= read -r file; do
    GGUF_FLAGS="$GGUF_FLAGS --include $file"
  done <<< "$PRODUCED_FILES"

  hf upload "$DST" "$UPLOAD_DIR" \
    $GGUF_FLAGS --include ".src_sha" --include "README.md" \
    --type model \
    --token "$HF_TOKEN"

  echo ">>> Uploaded to https://huggingface.co/$DST"

  rm -rf "$UPLOAD_DIR"
done

echo ""
echo ">>> All done!"

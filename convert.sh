#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments
OWNER=""
ONE_MODEL=""
FILTER_REGEX=""
FORCE=false
KEEP=false
NO_UPLOAD=false
LLAMA_COMMIT=""
LOCAL_MODEL=""
LOCAL_LLAMA=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --one)
            ONE_MODEL="$2"
            shift 2
            ;;
        --filter)
            FILTER_REGEX="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --keep)
            KEEP=true
            shift
            ;;
        --no-upload)
            NO_UPLOAD=true
            shift
            ;;
        --llama-commit)
            LLAMA_COMMIT="$2"
            shift 2
            ;;
        --local-model)
            LOCAL_MODEL="$2"
            shift 2
            ;;
        --local-llama)
            LOCAL_LLAMA="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ -z "$OWNER" ]; then
    echo "Error: --owner is required"
    exit 1
fi

if [ -n "$ONE_MODEL" ] && [ -n "$FILTER_REGEX" ]; then
    echo "Error: --one and --filter are mutually exclusive"
    exit 1
fi

if [ -n "$LOCAL_MODEL" ] && [ ! -d "$LOCAL_MODEL" ]; then
    echo "Error: --local-model: no such directory: $LOCAL_MODEL"
    exit 1
fi

if [ -n "$LOCAL_LLAMA" ] && [ ! -d "$LOCAL_LLAMA" ]; then
    echo "Error: --local-llama: no such directory: $LOCAL_LLAMA"
    exit 1
fi

if [ "$NO_UPLOAD" = false ] && [ -z "${HF_TOKEN:-}" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    exit 1
fi

set -x

echo ">>> Installing HF CLI"
pip install -r requirements.txt

export HF_XET_HIGH_PERFORMANCE="${HF_XET_HIGH_PERFORMANCE:-1}"

repo_create_flags=(--type model --exist-ok)
upload_flags=()
if [ -n "$LOCAL_MODEL" ]; then
    repo_create_flags+=(--private)
    upload_flags+=(--private)
fi

ensure_destination_repo() {
    local repo_id="$1"
    hf repos create "$repo_id" "${repo_create_flags[@]}"
    if [ -n "$LOCAL_MODEL" ]; then
        hf repos settings "$repo_id" --private
    fi
}

# hf upload is resumable (re-run skips committed files, dedupes uploaded shards),
# so retry transient failures like server-side read timeouts.
hf_upload_with_retry() {
    local attempts="${HF_UPLOAD_ATTEMPTS:-3}"
    local attempt=1
    while true; do
        if "$@"; then
            return 0
        fi
        if [ "$attempt" -ge "$attempts" ]; then
            return 1
        fi
        echo ">>> hf upload failed (attempt $attempt/$attempts). Retrying in $((attempt * 10))s..."
        sleep $((attempt * 10))
        attempt=$((attempt + 1))
    done
}

# Check HF_TOKEN has write access to owner when uploading
if [ "$NO_UPLOAD" = false ]; then
    if ! hf repos create "${OWNER}/__test-permissions" "${repo_create_flags[@]}" 2>/dev/null; then
        echo "Error: HF_TOKEN does not have write access to '$OWNER'"
        exit 1
    fi
fi

# Build list of configs to process (early validation before expensive setup)
if [ -n "$ONE_MODEL" ]; then
    config_paths=("models/${ONE_MODEL}/config.sh")
    if [ ! -f "${config_paths[0]}" ]; then
        echo "Error: No config.sh found for model '$ONE_MODEL'"
        exit 1
    fi
elif [ -n "$FILTER_REGEX" ]; then
    config_paths=()
    for candidate in models/*/config.sh; do
        dir=$(basename "$(dirname "$candidate")")
        if echo "$dir" | grep -qE "$FILTER_REGEX"; then
            config_paths+=("$candidate")
        fi
    done
    if [ ${#config_paths[@]} -eq 0 ]; then
        echo "Error: No models matched filter '$FILTER_REGEX'"
        exit 1
    fi
else
    config_paths=(models/*/config.sh)
fi

# Cross-platform CPU count
if command -v nproc &>/dev/null; then
    CPU_COUNT=$(nproc)
elif command -v sysctl &>/dev/null; then
    CPU_COUNT=$(sysctl -n hw.ncpu)
else
    CPU_COUNT=4
fi

LLAMA_DIR="llama.cpp"

echo ">>> Preparing llama.cpp"
if [ -n "$LOCAL_LLAMA" ]; then
    LLAMA_DIR="$(cd "$LOCAL_LLAMA" && pwd)"
    echo ">>> Using local llama.cpp: $LLAMA_DIR"
elif [ -d "llama.cpp" ]; then
    echo ">>> llama.cpp already exists"
    if [ -n "$LLAMA_COMMIT" ]; then
        cd llama.cpp && git fetch --unshallow 2>/dev/null || git fetch --all && git checkout "$LLAMA_COMMIT" && cd ..
    else
        cd llama.cpp && git checkout master && git pull && cd ..
    fi
else
    if [ -n "$LLAMA_COMMIT" ]; then
        git clone https://github.com/ggml-org/llama.cpp.git
        cd llama.cpp && git checkout "$LLAMA_COMMIT" && cd ..
    else
        git clone --depth 1 https://github.com/ggml-org/llama.cpp.git
    fi
fi

echo ">>> Building llama-quantize"
(cd "$LLAMA_DIR" && mkdir -p build && cd build && \
    cmake .. -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_UI=OFF && \
    make -j"$CPU_COUNT" llama-quantize)

# Iterate over selected config(s)
for config_path in "${config_paths[@]}"; do
    script_dir="$(dirname "$config_path")"

    # Clean up DEP_* and PATH_* from previous iteration
    for var in $(compgen -v | grep -E '^(DEP_|PATH_)' || true); do
        unset "$var"
    done

    source "$config_path"

    display="${DISPLAY_NAME}"
    dest="${OWNER}/${DEST_REPO}"
    upload_dir="./upload-${display//-/_}"

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ">>> Processing: $display → $dest"
    echo "═══════════════════════════════════════════════════════════"

    # Collect all DEP_* variable keys (e.g. PRIMARY, DFLASH, EAGLE3)
    dep_keys=$(compgen -v | grep '^DEP_' | sed 's/^DEP_//' | sort)

    # Fetch current SHAs for all dependencies
    current_sha_lines=""
    for key in $dep_keys; do
        repo_var="DEP_$key"
        repo="${!repo_var}"

        if [ -n "$LOCAL_MODEL" ]; then
            sha="local"
        else
            echo ">>> Checking for updates in $repo ($key)"
            sha=$(python3 -c "import urllib.request, json, sys; print(json.load(urllib.request.urlopen('https://huggingface.co/api/models/' + sys.argv[1]))['sha'])" "$repo")

            if [ -z "$sha" ]; then
                echo "Error: Failed to retrieve model info from Hugging Face for $repo"
                exit 1
            fi
        fi

        current_sha_lines+="${key}=${sha}"$'\n'
    done

    if [ "$FORCE" = true ] || [ "$NO_UPLOAD" = true ]; then
        echo ">>> Skipping destination SHA check, converting locally"
        needs_convert=true
    else
        # Read last-processed SHAs from destination repo
        last_sha_file=$(curl -Ls "https://huggingface.co/$dest/resolve/main/.src_sha" 2>/dev/null || echo "")

        # Compare — re-convert if ANY dependency changed
        needs_convert=false
        for key in $dep_keys; do
            current=$(echo "$current_sha_lines" | grep "^${key}=" | cut -d= -f2-)
            last=$(echo "$last_sha_file" | grep "^${key}=" | cut -d= -f2- 2>/dev/null || echo "")

            if [ "$current" != "$last" ]; then
                echo ">>> $key changed (current: ${current:0:8}…, last: ${last:0:8}…)"
                needs_convert=true
                break
            fi
        done
    fi

    if [ "$needs_convert" = false ]; then
        echo ">>> No dependency changes detected. Uploading README only."
        if [ "$KEEP" = false ]; then
            rm -rf "$upload_dir"
        fi
        mkdir -p "$upload_dir"
        sed "s/__owner__/$OWNER/g" "$script_dir/README.md" > "$upload_dir/README.md"
        if [ "$NO_UPLOAD" = false ]; then
            ensure_destination_repo "$dest"
            hf_upload_with_retry hf upload "$dest" "$upload_dir" "${upload_flags[@]}" --include "README.md" --type model
        fi
        if [ "$KEEP" = false ]; then
            rm -rf "$upload_dir"
        fi
        continue
    fi

    # Download all dependencies
    if [ "$KEEP" = false ]; then
        rm -rf "$upload_dir"
    fi
    mkdir -p "$upload_dir"
    sed "s/__owner__/$OWNER/g" "$script_dir/README.md" > "$upload_dir/README.md"

    temp_dirs=()
    for key in $dep_keys; do
        repo_var="DEP_$key"
        repo="${!repo_var}"

        if [ -n "$LOCAL_MODEL" ]; then
            echo ">>> Using local model for $key: $LOCAL_MODEL"
            export "PATH_$key=$LOCAL_MODEL"
            continue
        fi

        temp_dir="./model-temp-${display//-/_}-${key}"
        temp_dirs+=("$temp_dir")

        echo ">>> Downloading $repo → $key"
        hf download "$repo" --local-dir "$temp_dir"

        export "PATH_$key=$temp_dir"
    done

    echo ">>> Running conversion script: $script_dir/convert.sh"
    bash "$script_dir/convert.sh" "$upload_dir" "$LLAMA_DIR" 2>&1 | tee "$upload_dir/convert.log"

    # Read produced files from manifest
    if [ ! -f "$upload_dir/.produced_files" ]; then
        echo "Error: Conversion did not produce .produced_files manifest"
        exit 1
    fi
    produced_files=$(cat "$upload_dir/.produced_files")

    # Write .src_sha with all dependency SHAs
    printf "%s" "$current_sha_lines" > "$upload_dir/.src_sha"

    gguf_flags=""

    while IFS= read -r file; do
        [ -n "$file" ] && gguf_flags="$gguf_flags --include $file"
    done <<< "$produced_files"

    if [ "$NO_UPLOAD" = false ]; then
        ensure_destination_repo "$dest"
        if ! hf_upload_with_retry hf upload "$dest" "$upload_dir" "${upload_flags[@]}" $gguf_flags --include ".src_sha" --include "README.md" --include "convert.log" --type model; then
            # fallback: one file per commit
            echo ">>> Combined upload failed after retries. Falling back to per-file uploads."
            upload_failed=false
            while IFS= read -r file; do
                [ -n "$file" ] || continue
                echo ">>> Uploading $file (per-file fallback)"
                hf_upload_with_retry hf upload "$dest" "$upload_dir/$file" "${upload_flags[@]}" --type model || upload_failed=true
            done <<< "$produced_files"
            for meta in .src_sha README.md convert.log; do
                echo ">>> Uploading $meta (per-file fallback)"
                hf_upload_with_retry hf upload "$dest" "$upload_dir/$meta" "${upload_flags[@]}" --type model || upload_failed=true
            done
            if [ "$upload_failed" = true ]; then
                echo "Error: upload to $dest failed"
                exit 1
            fi
        fi
        echo ">>> Uploaded to https://huggingface.co/$dest"
    fi


    if [ "$KEEP" = false ]; then
        rm -rf "$upload_dir"
        for dir in "${temp_dirs[@]}"; do
            rm -rf "$dir"
        done
    fi
    for key in $dep_keys; do
        unset "PATH_$key"
    done
done

echo ""
echo ">>> All done!"

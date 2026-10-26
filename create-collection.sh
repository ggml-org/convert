#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create or look up a collection on Hugging Face and print its slug.
#
# Collections are created private by default to avoid accidentally
# publishing an unreleased collection too early. Use --public to create a
# public collection.
#
# By default the collection is titled with the first 32 characters of the
# sha256 of --name so an unreleased model name is not exposed to other members
# of the owner organization. Use --no-hash to title the collection with the
# name as-is. The slug of a hashed collection can be looked up again later with
# --lookup using the same name so that we can keep track of the collection if we
# have multiple new models in progress.
#
# The slug is stable across title changes, so it is safe to share before the
# final model name is known. The collection can later be renamed via the Hub
# UI without breaking the link.
#
# Requires HF_TOKEN with collection rights on the owner's namespace.
#
# Usage:
#   bash create-collection.sh --owner <owner> --name <name> [--public] [--no-hash] [--description <text>]
#   bash create-collection.sh --lookup --owner <owner> --name <name> [--no-hash]
#
# Examples:
#   # Private collection (the default) titled with the sha256 of the name
#   bash create-collection.sh --owner ggml-org --name "New Model"
#
#   # Public collection titled with the name as-is, for a released model
#   bash create-collection.sh --owner ggml-org --name "Gemma 4" --public --no-hash
#
#   # Look up the slug of a collection created earlier from its name
#   bash create-collection.sh --lookup --owner ggml-org --name "New Model"

sha256_of() {
    local hash
    if command -v sha256sum &>/dev/null; then
        hash=$(printf '%s' "$1" | sha256sum | cut -d' ' -f1)
    elif command -v shasum &>/dev/null; then
        hash=$(printf '%s' "$1" | shasum -a 256 | cut -d' ' -f1)
    else
        echo "Error: sha256sum (or shasum) not found"
        exit 1
    fi
    echo "${hash:0:32}"
}

OWNER=""
NAME=""
LOOKUP=false
PUBLIC=false
HASH=true
DESCRIPTION=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --name)
            NAME="$2"
            shift 2
            ;;
        --lookup)
            LOOKUP=true
            shift
            ;;
        --public)
            PUBLIC=true
            shift
            ;;
        --no-hash)
            HASH=false
            shift
            ;;
        --description)
            DESCRIPTION="$2"
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

if [ -z "$NAME" ]; then
    echo "Error: --name is required"
    exit 1
fi

if [ -z "${HF_TOKEN:-}" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    exit 1
fi

if [ "$HASH" = true ]; then
    TITLE="$(sha256_of "$NAME")"
else
    TITLE="$NAME"
fi

if [ "$LOOKUP" = true ]; then
    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 is not installed"
        exit 1
    fi
    result=$(python3 - "$OWNER" "$TITLE" <<'EOF'
import sys

from huggingface_hub import HfApi

owner, title = sys.argv[1], sys.argv[2]
matches = [c.slug for c in HfApi().list_collections(owner=owner) if c.title == title]

if not matches:
    sys.exit(
        f"Error: no collection with title '{title}' found in namespace '{owner}'. "
        f"Note: name matching is exact (case-sensitive)."
    )
print("\n".join(matches))
EOF
    )

    echo ""
    while IFS= read -r slug; do
        [ -n "$slug" ] && echo ">>> Found collection: https://huggingface.co/collections/$slug"
    done <<< "$result"
    echo "$result"
else
    if ! command -v hf &>/dev/null; then
        echo "Error: HF cli is not installed. Please install using requirements.txt"
        exit 1
    fi
    create_flags=(--namespace "$OWNER")
    if [ "$PUBLIC" = false ]; then
        create_flags+=(--private)
    fi
    if [ -n "$DESCRIPTION" ]; then
        create_flags+=(--description "$DESCRIPTION")
    fi
    set -x
    slug=$(hf collections create "$TITLE" "${create_flags[@]}" --quiet)
    set +x

    echo ""
    echo ">>> Collection created: https://huggingface.co/collections/$slug"
    if [ "$HASH" = true ]; then
        echo ">>> Titled with sha256 of '$NAME' = $TITLE"
        echo ">>> Look it up later with: bash create-collection.sh --lookup --owner $OWNER --name \"$NAME\""
    fi
    echo "$slug"
fi

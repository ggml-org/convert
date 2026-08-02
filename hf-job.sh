#!/bin/bash
set -euo pipefail

# Hugging Face Job to run convert.sh on HF infrastructure
# Usage: ./hf-job.sh --owner <owner> [--one <name>] [--filter <regex>] [--branch <name>] [--timeout <seconds>] [--hardware <flavor>]

echo ">>> Starting HF Job: Model Convert & Quantize"

# Collect arguments to pass to convert.sh
OWNER=""
BRANCH=""
TIMEOUT="1h"
HARDWARE="cpu-performance"
CONVERT_ARGS=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --one)
            CONVERT_ARGS="$CONVERT_ARGS --one $2"
            shift 2
            ;;
        --filter)
            CONVERT_ARGS="$CONVERT_ARGS --filter $2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --force)
            CONVERT_ARGS="$CONVERT_ARGS --force"
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --hardware)
            HARDWARE="$2"
            shift 2
            ;;
        --llama-commit)
            CONVERT_ARGS="$CONVERT_ARGS --llama-commit $2"
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

CHECKOUT_CMD=""
if [ -n "$BRANCH" ]; then
    CHECKOUT_CMD="git checkout $BRANCH"
fi

hf jobs run \
    --namespace "$OWNER" \
    --timeout "$TIMEOUT" \
    --flavor "$HARDWARE" \
    --secrets HF_TOKEN \
    --env HF_HUB_ENABLE_HF_XET=1 \
    python:3.11-slim \
    bash -c '
    set -euo pipefail

    # Install system dependencies
    apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      cmake

    # Clone the conversion scripts
    git clone https://github.com/ggml-org/convert.git /tmp/convert
    cd /tmp/convert

    '"$CHECKOUT_CMD"'

    # Run the conversion script
    bash convert.sh --owner '"$OWNER"' '"$CONVERT_ARGS"'
'

echo ">>> Job submitted. Check logs with: hf jobs logs"

#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --machine_progress)
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
exec "$SCRIPT_DIR/generate-thumbnails-magick.sh" "${ARGS[@]}"

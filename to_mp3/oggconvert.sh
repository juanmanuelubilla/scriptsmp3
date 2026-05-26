#!/bin/bash

root_directory="$1"
quality="${2:-128}"

if [ -z "$root_directory" ] || [ ! -d "$root_directory" ]; then
    echo "Uso: $0 <directorio> [bitrate_kbps]"
    exit 1
fi

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/convert_mp3.sh
source "$_REPO_ROOT/lib/convert_mp3.sh"

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg no está instalado."
    exit 1
fi

export quality

convert_to_mp3() {
    local input_file="$1"
    local output_file="${input_file%.ogg}.mp3"

    if [ -f "$output_file" ]; then
        echo "[OMITIDO] Ya existe: $output_file"
        return 0
    fi

    if ffmpeg_ogg_to_mp3 "$input_file" "$output_file" "$quality"; then
        echo "[OK] $input_file"
    else
        echo "[ERROR] $input_file"
    fi
}

export -f convert_to_mp3
export -f ffmpeg_ogg_to_mp3

num_threads=$(nproc)

find "$root_directory" -type f -name "*.ogg" -print0 | \
xargs -0 -n 1 -P "$num_threads" -I {} bash -c 'convert_to_mp3 "$1"' _ {}

echo "Conversión completada."

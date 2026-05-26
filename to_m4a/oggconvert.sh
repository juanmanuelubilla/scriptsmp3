#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|        CONVIRTIENDO ARCHIVOS DE OGG A M4A       |\033[0m"
echo -e "\033[1;36m|              (ffmpeg / AAC — Debian 13)          |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

root_directory="$1"
quality="${2:-128}"

if [ -z "$root_directory" ]; then
    echo "Uso: $0 <directorio> [calidad_kbps (64|96|128|192|256|320)]"
    exit 1
fi

if [ ! -d "$root_directory" ]; then
    echo "Error: El directorio '$root_directory' no existe."
    exit 1
fi

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/convert_m4a.sh
source "$_REPO_ROOT/lib/convert_m4a.sh"

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg no está instalado."
    exit 1
fi

convert_to_m4a() {
    local input_file="$1"
    local output_file="${input_file%.ogg}.m4a"

    if [ -f "$output_file" ]; then
        echo -e "\033[1;33m[OMITIDO] Ya existe: $output_file\033[0m"
        return 0
    fi

    if ffmpeg_to_m4a "$input_file" "$output_file" "$quality"; then
        echo -e "\033[1;32m[OK] Conversión exitosa: $input_file\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Falló la conversión: $input_file\033[0m"
    fi
}

export -f convert_to_m4a
export -f ffmpeg_to_m4a
export quality

nproc_val=$(nproc)

find "$root_directory" -type f -name "*.ogg" -print0 | \
xargs -0 -n 1 -P "$nproc_val" -I {} bash -c 'convert_to_m4a "$1"' _ {}

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo -e "\033[1;36mConversión completada en ${minutes}m ${seconds}s (${nproc_val} procesos, ${quality} kbps AAC).\033[0m"

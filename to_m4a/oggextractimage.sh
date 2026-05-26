#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m| EXTRAYENDO COVERS DE ARCHIVOS OGG CON FFmpeg... |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

root_directory="$1"

if [ ! -d "$root_directory" ]; then
    echo -e "\033[1;31mError: El directorio '$root_directory' no existe.\033[0m"
    exit 1
fi

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/ui_common.sh
source "$_REPO_ROOT/lib/ui_common.sh"

NUM_THREADS=$(nproc)

mapfile -d '' files < <(find "$root_directory" -type f -name "*.ogg" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
    echo -e "\033[1;33mNo se encontraron archivos OGG.\033[0m"
    exit 0
fi

mutex="/tmp/cover_extract_lock.$$"
count_file="/tmp/cover_extract_count.$$"
touch "$mutex"
ui_progress_file_init "$count_file"

SUCCESS_LOG=$(mktemp)
ERROR_LOG=$(mktemp)

extract_cover() {
    local input_file="$1"
    local output_file="${input_file%.ogg}.jpg"

    if ffmpeg -i "$input_file" 2>&1 | grep -q "Video: mjpeg"; then
        if ffmpeg -i "$input_file" -an -vcodec copy "$output_file" -y -loglevel error 2>/dev/null; then
            echo -e "\033[1;32m[OK] Cover extraído de: $input_file\033[0m" >>"$SUCCESS_LOG"
        else
            echo -e "\033[1;31m[ERROR] Fallo al guardar: $output_file\033[0m" >>"$ERROR_LOG"
        fi
    else
        echo -e "\033[1;33m[SKIP] No hay cover en: $input_file\033[0m" >>"$ERROR_LOG"
    fi

    ui_progress_file_tick "$count_file" "$total_files" "$mutex"
}

export -f extract_cover
export -f ui_progress_file_tick ui_bar_render
export total_files mutex count_file SUCCESS_LOG ERROR_LOG

printf '%s\0' "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" -I {} bash -c 'extract_cover "$1"' _ {}

ui_bar_finish

echo ""
echo -e "\033[1;36mResumen de extracción:\033[0m"
[ -s "$SUCCESS_LOG" ] && cat "$SUCCESS_LOG"
[ -s "$ERROR_LOG" ] && cat "$ERROR_LOG"

rm -f "$mutex" "$count_file" "$SUCCESS_LOG" "$ERROR_LOG"

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))
echo ""
echo "Extracción de covers completada en ${minutes}m ${seconds}s"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

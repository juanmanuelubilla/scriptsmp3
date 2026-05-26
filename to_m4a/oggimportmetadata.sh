#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|     IMPORTANDO METADATA OGG → M4A               |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/ui_common.sh
source "$_REPO_ROOT/lib/ui_common.sh"

get_metadata() {
    mediainfo --Output="General;%Track%|%Performer%|%Title%|%Album%|%Genre%|%Year%" "$1"
}

add_aac_metadata() {
    local aac_file="$2"
    if AtomicParsley "$aac_file" --overWrite \
        --tracknum "$3" \
        --artist "$4" \
        --title "$5" \
        --album "$6" \
        --genre "$7" \
        --year "$8" &>/dev/null; then
        echo -e "\033[1;32m[OK] Metadata importada en: $aac_file\033[0m" >>"$DETAIL_LOG"
    else
        echo -e "\033[1;31m[ERROR] Falló importación en: $aac_file\033[0m" >>"$DETAIL_LOG"
    fi
}

root_directory="$1"

if [ ! -d "$root_directory" ]; then
  echo -e "\033[1;31mError: El directorio '$root_directory' no existe.\033[0m"
  exit 1
fi

NUM_THREADS=$(nproc)
mutex="/tmp/import_metadata_lock.$$"
count_file="/tmp/import_metadata_count.$$"
touch "$mutex"
DETAIL_LOG=$(mktemp)

import_metadata() {
    local ogg_file="$1"
    local metadata aac_file

    IFS='|' read -r -a metadata <<< "$(get_metadata "$ogg_file")"
    aac_file="${ogg_file%.ogg}.m4a"

    if [ ! -f "$aac_file" ]; then
      echo -e "\033[1;33m[WARN] Archivo M4A no encontrado para: $ogg_file\033[0m" >>"$DETAIL_LOG"
    else
      add_aac_metadata "$ogg_file" "$aac_file" \
        "${metadata[0]}" "${metadata[1]}" "${metadata[2]}" \
        "${metadata[3]}" "${metadata[4]}" "${metadata[5]}"
    fi

    ui_progress_file_tick "$count_file" "$total_files" "$mutex"
}

mapfile -d '' files < <(find "$root_directory" -type f -name "*.ogg" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
  echo -e "\033[1;33mNo se encontraron archivos OGG en el directorio.\033[0m"
  rm -f "$DETAIL_LOG" "$mutex"
  exit 0
fi

ui_progress_file_init "$count_file"

export -f get_metadata add_aac_metadata import_metadata
export -f ui_progress_file_tick ui_bar_render
export total_files mutex count_file DETAIL_LOG

printf '%s\0' "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" -I {} bash -c 'import_metadata "$1"' _ {}

ui_bar_finish
echo ""
[ -s "$DETAIL_LOG" ] && cat "$DETAIL_LOG"
rm -f "$DETAIL_LOG" "$mutex" "$count_file"

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo -e "\033[1;36mImportación completada en ${minutes}m ${seconds}s.\033[0m"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

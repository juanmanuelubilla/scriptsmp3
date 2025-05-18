#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|     IMPORTANDO METADATA DEL ARCHIVO OGG         |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

# Función para obtener la metadata utilizando `mediainfo`
get_metadata() {
    local file="$1"
    mediainfo --Output="General;%Track%|%Performer%|%Title%|%Album%|%Genre%|%Year%" "$file"
}

# Función para agregar la metadata AAC a un archivo M4A utilizando `AtomicParsley`
add_aac_metadata() {
    local ogg_file="$1"
    local aac_file="$2"
    local track="$3"
    local artist="$4"
    local title="$5"
    local album="$6"
    local genre="$7"
    local year="$8"

    if AtomicParsley "$aac_file" --overWrite \
        --tracknum "$track" \
        --artist "$artist" \
        --title "$title" \
        --album "$album" \
        --genre "$genre" \
        --year "$year" &>/dev/null; then
        echo -e "\033[1;32m[OK] Metadata importada en: $aac_file\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Falló importacion en: $aac_file\033[0m"
    fi
}

root_directory="$1"

if [ ! -d "$root_directory" ]; then
  echo -e "\033[1;31mError: El directorio '$root_directory' no existe.\033[0m"
  exit 1
fi

NUM_THREADS=$(nproc)
bar_width=50
mutex="/tmp/import_metadata_lock.$$"
touch "$mutex"
processed=0

update_progress() {
    local p=$1
    local total=$2
    local percent=$(( p * 100 / total ))
    local fill=$(( p * bar_width / total ))
    local bar=$(printf "%-${fill}s" "#" | tr ' ' '#')
    local space=$(printf "%-$((bar_width - fill))s")
    echo -ne "\r[${bar}${space}] ${percent}% (${p}/${total})"
}

import_metadata() {
    local ogg_file="$1"
    local metadata
    IFS='|' read -r -a metadata <<< "$(get_metadata "$ogg_file")"

    local track="${metadata[0]}"
    local artist="${metadata[1]}"
    local title="${metadata[2]}"
    local album="${metadata[3]}"
    local genre="${metadata[4]}"
    local year="${metadata[5]}"

    local aac_file="${ogg_file%.ogg}.m4a"

    if [ ! -f "$aac_file" ]; then
      echo -e "\033[1;33m[WARN] Archivo M4A no encontrado para: $ogg_file\033[0m"
    else
      add_aac_metadata "$ogg_file" "$aac_file" "$track" "$artist" "$title" "$album" "$genre" "$year"
    fi

    {
      flock 200
      ((processed++))
      update_progress "$processed" "$total_files"
    } 200>"$mutex"
}

export -f get_metadata add_aac_metadata import_metadata update_progress
export bar_width mutex
export -n processed
export total_files

mapfile -d '' files < <(find "$root_directory" -type f -name "*.ogg" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
  echo -e "\033[1;33mNo se encontraron archivos OGG en el directorio.\033[0m"
  exit 0
fi

printf "%s\0" "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" bash -c 'import_metadata "$0"'

echo -e "\n"

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo -e "\033[1;36mImportación completada en ${minutes}m ${seconds}s.\033[0m"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

#!/bin/bash

# Función para obtener la metadata utilizando `mediainfo`
get_metadata() {
    local file="$1"
    mediainfo --Output="General;%Track%|%Performer%|%Title%|%Album%|%Genre%|%Year%" "$file"
}

# Función para agregar la metadata AAC a un archivo M4A utilizando `AtomicParsley`
add_aac_metadata() {
    local mp3_file="$1"
    local aac_file="${mp3_file%.mp3}.m4a"

    # Extraer metadata del MP3
    IFS='|' read -r -a metadata <<< "$(get_metadata "$mp3_file")"
    track="${metadata[0]}"
    artist="${metadata[1]}"
    title="${metadata[2]}"
    album="${metadata[3]}"
    genre="${metadata[4]}"
    year="${metadata[5]}"

    # Agregar la metadata al archivo M4A
    AtomicParsley "$aac_file" --overWrite \
        --tracknum "$track" \
        --artist "$artist" \
        --title "$title" \
        --album "$album" \
        --genre "$genre" \
        --year "$year" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Metadata añadida al archivo: $aac_file"
    else
        echo "Error al procesar: $mp3_file"
    fi
}

# Ruta del directorio raíz donde se encuentran los archivos MP3
root_directory="$1"

# Validar que se haya proporcionado un directorio
if [ -z "$root_directory" ]; then
    echo "Uso: $0 <directorio_raíz>"
    exit 1
fi

# Obtener el número de hilos del procesador
NUM_THREADS=$(nproc)

# Buscar archivos MP3 y procesarlos en paralelo con xargs
find "$root_directory" -type f -name "*.mp3" -print0 | \
xargs -0 -n 1 -P "$NUM_THREADS" bash -c '
    mp3_file="$0"
    aac_file="${mp3_file%.mp3}.m4a"
    IFS="|" read -r -a metadata <<< "$(mediainfo --Output="General;%Track%|%Performer%|%Title%|%Album%|%Genre%|%Year%" "$mp3_file")"
    track="${metadata[0]}"
    artist="${metadata[1]}"
    title="${metadata[2]}"
    album="${metadata[3]}"
    genre="${metadata[4]}"
    year="${metadata[5]}"
    AtomicParsley "$aac_file" --overWrite \
        --tracknum "$track" \
        --artist "$artist" \
        --title "$title" \
        --album "$album" \
        --genre "$genre" \
        --year "$year" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Metadata añadida al archivo: $aac_file"
    else
        echo "Error al procesar: $mp3_file"
    fi
' 

echo "Proceso completado."

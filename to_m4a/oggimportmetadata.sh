#!/bin/bash

# Función para obtener la metadata utilizando `mediainfo`
get_metadata() {
    local file="$1"
    mediainfo --Output="General;%Track%|%Performer%|%Title%|%Album%|%Genre%|%Year%" "$file"
}

# Función para agregar la metadata AAC a un archivo M4A utilizando `AtomicParsley`
add_aac_metadata() {
    local ogg_file="$1"
    local aac_file="$2"
    AtomicParsley "$aac_file" --overWrite \
        --tracknum "$track" \
        --artist "$artist" \
        --title "$title" \
        --album "$album" \
        --genre "$genre" \
        --year "$year"
}

# Ruta del directorio raíz donde se encuentran los archivos Ogg
root_directory="$1"

# Buscar archivos Ogg en el directorio raíz y subcarpetas
while IFS= read -r -d $'\0' ogg_file; do
    # Obtener la metadata del archivo Ogg
    IFS='|' read -r -a metadata <<< "$(get_metadata "$ogg_file")"

    # Extraer la información de la metadata
    track="${metadata[0]}"
    artist="${metadata[1]}"
    title="${metadata[2]}"
    album="${metadata[3]}"
    genre="${metadata[4]}"
    year="${metadata[5]}"

    # Generar el nombre del archivo M4A utilizando el mismo nombre que el archivo Ogg
    aac_file="${ogg_file%.ogg}.m4a"

    # Agregar la metadata AAC al archivo M4A
    add_aac_metadata "$ogg_file" "$aac_file"

done < <(find "$root_directory" -type f -name "*.ogg" -print0)

echo "Proceso completado."


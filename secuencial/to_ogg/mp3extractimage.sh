#!/bin/bash

# Función para extraer el cover art de un archivo MP3 y guardarlo como imagen
function extract_cover() {
    local mp3_file="$1"
    local output_file="${mp3_file%.mp3}.jpg"

    # Extraer el cover art utilizando ffmpeg
    ffmpeg -i "${mp3_file}" -an -vcodec copy "${output_file}" < /dev/null 2> /dev/null

    if [ $? -eq 0 ]; then
        echo "Cover extraído de: ${mp3_file}"
    else
        echo "No se pudo extraer el cover de: ${mp3_file}"
    fi
}

# Función recursiva para buscar archivos MP3 y extraer sus covers
function process_directory() {
    local dir="$1"
    shopt -s nullglob

    for file in "${dir}"/*.mp3; do
        if [ -f "$file" ]; then
            extract_cover "$file"
        fi
    done

    for sub_dir in "${dir}"/*; do
        if [ -d "$sub_dir" ]; then
            process_directory "$sub_dir"
        fi
    done
}

# Comprobamos si se proporcionó una ruta como argumento, de lo contrario, usamos el directorio actual.
if [ $# -eq 1 ]; then
    target_directory="$1"
else
    target_directory="."
fi

# Iniciamos el procesamiento
process_directory "$target_directory"


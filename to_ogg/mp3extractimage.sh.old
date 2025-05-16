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

# Guardamos la función en un archivo temporal para poder usarla con xargs
export -f extract_cover

# Función para buscar archivos MP3 y procesarlos en paralelo
function process_directory() {
    local dir="$1"

    # Buscar todos los archivos MP3 y procesarlos en paralelo con xargs
    find "$dir" -type f -name "*.mp3" -print0 | xargs -0 -n 1 -P "$NUM_THREADS" bash -c 'extract_cover "$@"' _
}

# Comprobamos si se proporcionó una ruta como argumento, de lo contrario, usamos el directorio actual.
if [ $# -eq 1 ]; then
    target_directory="$1"
else
    target_directory="."
fi

# Obtener el número de núcleos del procesador
NUM_THREADS=$(nproc)

# Iniciamos el procesamiento
process_directory "$target_directory"


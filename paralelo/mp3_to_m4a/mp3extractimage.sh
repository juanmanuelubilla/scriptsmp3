#!/bin/bash

# Función para extraer el cover de un archivo MP3
extract_cover() {
    input_file="$1"
    output_file="${input_file%.mp3}.jpg"
    
    # Extraer el cover art y redirigir errores a /dev/null
    ffmpeg -i "$input_file" -an -vcodec copy "$output_file" 2>/dev/null

    # Verificar si ffmpeg tuvo éxito
    if [ $? -eq 0 ]; then
        echo "Cover extraído de: $input_file"
    else
        echo "No se pudo extraer el cover de: $input_file"
    fi
}

# Función para recorrer las carpetas y subcarpetas y extraer los covers en paralelo
process_directory() {
    local dir="$1"
    local ext=".mp3"

    # Encontrar todos los archivos MP3 y procesarlos en paralelo con xargs
    find "$dir" -type f -name "*$ext" -print0 | xargs -0 -n 1 -P "$NUM_THREADS" bash -c '
        input_file="$1"
        output_file="${input_file%.mp3}.jpg"
        ffmpeg -i "$input_file" -an -vcodec copy "$output_file" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Cover extraído de: $input_file"
        else
            echo "No se pudo extraer el cover de: $input_file"
        fi
    ' _
}

# Directorio raíz desde donde se ejecutará el script
root_directory="$1"

# Validar que se haya proporcionado un directorio
if [ -z "$root_directory" ]; then
    echo "Uso: $0 <directorio_raíz>"
    exit 1
fi

# Obtener el número de núcleos del procesador
NUM_THREADS=$(nproc)

# Ejecutar la función para recorrer las carpetas y extraer los covers
process_directory "$root_directory"

echo "Extracción de covers completada."

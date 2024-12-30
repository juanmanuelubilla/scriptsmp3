#!/bin/bash

# Función para extraer el cover de un archivo OGG
extract_cover() {
    input_file="$1"
    output_file="${input_file%.ogg}.jpg"
    ffmpeg -i "$input_file" -an -vcodec copy "$output_file" 2>/dev/null
}

# Función para recorrer las carpetas y subcarpetas
traverse_folders() {
    local dir="$1"
    local ext=".ogg"
    local files=()

    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$dir" -type f -name "*$ext" -print0)

    for file in "${files[@]}"; do
        extract_cover "$file"
    done
}

# Directorio raíz desde donde se ejecutará el script
root_directory="$1"

# Ejecutar la función para recorrer las carpetas y extraer los covers
traverse_folders "$root_directory"

echo "Extracción de covers completada."

#!/bin/bash

# Directorio raíz desde donde se buscarán los archivos OGG
root_directory="$1"

# Calidad de la conversión (opciones: 64, 128, 192, 256, 320)
quality="$2"

# Función para convertir un archivo OGG a M4A con la calidad indicada
convert_to_m4a() {
    input_file="$1"
    output_file="${input_file%.ogg}.m4a"
    oggdec -o - "$input_file" | faac -b "$quality" -o "$output_file" -
}

# Función para recorrer las carpetas y subcarpetas, convertir los archivos y borrar los OGG
traverse_folders() {
    local dir="$1"
    local ext=".ogg"
    local files=()

    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$dir" -type f -name "*$ext" -print0)

    for file in "${files[@]}"; do
        convert_to_m4a "$file"
        #rm "$file"
    done
}

# Ejecutar la función para recorrer las carpetas y convertir los archivos
traverse_folders "$root_directory"

echo "Conversión y eliminación de archivos OGG completada."

#!/bin/bash

# Directorio raíz desde donde se buscarán los archivos OGG
root_directory="$1"

# Calidad de la conversión en kbps (opciones: 64, 128, 192, 256, 320)
quality="$2"

# Función para convertir un archivo OGG a MP3 con la calidad indicada
convert_to_mp3() {
    input_file="$1"
    output_file="${input_file%.ogg}.mp3"
    oggdec -o - "$input_file" | lame --add-id3v2 -b "$quality" - "$output_file"
}

# Función para recorrer las carpetas y subcarpetas, convertir los archivos y borrar los OGG
traverse_folders() {
    local dir="$1"
    local ext=".ogg"
    
    # Obtener el número de hilos disponibles
    num_threads=$(nproc)

    # Buscar todos los archivos OGG en el directorio y subdirectorios
    find "$dir" -type f -name "*$ext" -print0 | xargs -0 -n 1 -P "$num_threads" -I {} bash -c '
        convert_to_mp3() {
            input_file="$1"
            output_file="${input_file%.ogg}.mp3"
            oggdec -o - "$input_file" | lame --add-id3v2 -b "$quality" - "$output_file"
        }
        convert_to_mp3 "$1"
    ' _ {}
}

# Ejecutar la función para recorrer las carpetas y convertir los archivos
traverse_folders "$root_directory"

echo "Conversión completada."

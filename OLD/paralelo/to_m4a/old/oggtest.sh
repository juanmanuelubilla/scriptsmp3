#!/bin/bash

# Función para exportar metadata de OGG a M4A
export_metadata() {
    local ogg_file="$1"
    local m4a_file="${ogg_file%.ogg}.m4a"

    # Extraer la metadata del archivo OGG al archivo TXT temporal
    ogginfo "$ogg_file" | grep -v "METADATA_BLOCK_PICTURE" > metadata.txt

    # Leer los valores de metadata del archivo TXT
    local title=$(grep "title=" metadata.txt | sed 's/.*title=//')
    local artist=$(grep "artist=" metadata.txt | sed 's/.*artist=//')
    local album=$(grep "album=" metadata.txt | sed 's/.*album=//')

    # Crear el archivo M4A con la metadata
    ffmpeg -i "$ogg_file" -c copy -metadata title="$title" -metadata artist="$artist" -metadata album="$album" "$m4a_file"

    # Eliminar el archivo TXT temporal
    rm metadata.txt
}

# Función para procesar carpetas y subcarpetas
process_folder() {
    local folder="$1"

    # Recorre todos los archivos y carpetas en la ubicación actual
    find "$folder" -type f -name "*.ogg" | while read -r ogg_file; do
        export_metadata "$ogg_file"
    done
}

# Verifica si se proporcionó una ruta de carpeta como argumento
if [[ -z "$1" ]]; then
    echo "Uso: $0 ruta_de_carpeta"
    exit 1
fi

# Llama a la función para procesar carpetas y subcarpetas
process_folder "$1"

echo "Exportación de metadata completada."


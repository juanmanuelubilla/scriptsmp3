#!/bin/bash

# Función para exportar la metadata de un archivo OGG a un archivo TXT
export_metadata() {
    ogginfo "$1" | grep -v "METADATA_BLOCK_PICTURE" > "$2"
}

# Función para procesar carpetas y subcarpetas
process_folder() {
    local folder="$1"

    # Recorre todos los archivos y carpetas en la ubicación actual
    for item in "$folder"/*; do
        # Si es un archivo OGG, exporta la metadata a un archivo TXT
        if [[ -f "$item" && "$item" == *.ogg ]]; then
            local metadata_file="${item%.ogg}.txt"
            export_metadata "$item" "$metadata_file"
        fi

        # Si es una carpeta, procesa sus contenidos llamando a esta función recursivamente
        if [[ -d "$item" ]]; then
            process_folder "$item"
        fi
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


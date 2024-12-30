#!/bin/bash

# Ruta del directorio donde se copiarán los archivos sin metadata
dest_path="/mnt/HP-ENVY-LINUX/HDD120GB/test"

# Función para verificar si un archivo OGG tiene metadata musical
function has_metadata {
    if [ -n "$(vorbiscomment "$1")" ]; then
        return 0  # Tiene metadata
    else
        return 1  # No tiene metadata
    fi
}

# Función para copiar archivos OGG sin metadata al directorio destino
function copy_files_without_metadata {
    find "$1" -type f -name "*.ogg" | while read -r file; do
        if ! has_metadata "$file"; then
            # Obtener la ruta relativa del archivo respecto al directorio de origen
            rel_path="${file#"$1"/}"
            # Crear directorio de destino si no existe
            mkdir -p "$dest_path/$(dirname "$rel_path")"
            # Copiar el archivo respetando la estructura de carpetas
            cp "$file" "$dest_path/$rel_path"
            echo "Copiado: $file"
        fi
    done
}

# Ruta del directorio raíz donde buscar archivos OGG
root_dir="/mnt/R1/HDD3TB/NEW MUSIC"

copy_files_without_metadata "$root_dir"

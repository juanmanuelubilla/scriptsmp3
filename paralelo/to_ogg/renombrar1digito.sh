#!/bin/bash

# Directorio donde comenzar la búsqueda
dir="$1"

# Buscar archivos .ogg que empiecen con 1-, 2-, ..., 9-
find "$dir" -type f -name "*.ogg" | while read -r file; do
    # Obtener el nombre del archivo sin la ruta
    filename=$(basename "$file")

    # Verificar si el nombre empieza con un número entre 1 y 9 seguido de " -"
    if [[ "$filename" =~ ^([1-9])\ -.*\.ogg$ ]]; then
        # Agregar un cero al número
        newname="0${BASH_REMATCH[1]} -${filename:3}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"
    fi
done

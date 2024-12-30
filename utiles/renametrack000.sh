#!/bin/bash

# Directorio donde comenzar la búsqueda
dir="$1"

# Buscar archivos .ogg que comiencen con 3 o 4 dígitos seguidos de un espacio y un guion
find "$dir" -type f -name "*.ogg" | while read -r file; do
    # Obtener el nombre del archivo sin la ruta
    filename=$(basename "$file")

    # Verificar si el nombre empieza con 3 dígitos y tiene un formato '### - ... .ogg'
    if [[ "$filename" =~ ^0([0-9]{2})\ -.*\.ogg$ ]]; then
        # Renombrar quitando el primer cero (de 3 dígitos a 2)
        newname="${BASH_REMATCH[1]} -${filename:5}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 1000-1999 y tiene un formato '#### - ... .ogg'
    elif [[ "$filename" =~ ^10([0-9]{2})\ -.*\.ogg$ ]]; then
        # Renombrar quitando los dos primeros dígitos, dejando los últimos dos (de 4 dígitos a 2)
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 2000-2999
    elif [[ "$filename" =~ ^20([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 3000-3999
    elif [[ "$filename" =~ ^30([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 4000-4999
    elif [[ "$filename" =~ ^40([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 5000-5999
    elif [[ "$filename" =~ ^50([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 6000-6999
    elif [[ "$filename" =~ ^60([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 7000-7999
    elif [[ "$filename" =~ ^70([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 8000-8999
    elif [[ "$filename" =~ ^80([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"

    # Verificar si el nombre empieza con 4 dígitos en el rango 9000-9999
    elif [[ "$filename" =~ ^90([0-9]{2})\ -.*\.ogg$ ]]; then
        newname="${BASH_REMATCH[1]} -${filename:6}"
        mv "$file" "$(dirname "$file")/$newname"
        echo "Renombrado: $filename -> $newname"
    fi
done


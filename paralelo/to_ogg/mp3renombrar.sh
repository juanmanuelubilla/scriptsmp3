#!/bin/bash

# Verifica si se proporcionó el path de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 <path>"
    exit 1
fi

# Directorio base
base_path="$1"

# Verifica si el directorio existe
if [ ! -d "$base_path" ]; then
    echo "Error: El directorio '$base_path' no existe."
    exit 1
fi

# Función para limpiar nombres
clean_name() {
    local original_name="$1"
    local dir_name=$(dirname "$original_name")
    local base_name=$(basename "$original_name")

    # Reemplazar acentos por vocales sin acento
    local cleaned_name=$(echo "$base_name" | sed -e 'y/áéíóúÁÉÍÓÚ/aeiouAEIOU/')

    # Eliminar caracteres problemáticos para variables y mantener solo caracteres seguros
    cleaned_name=$(echo "$cleaned_name" | tr -cd '[:alnum:]._-' | sed 's/[ ]/_/g')

    # Renombrar si el nombre fue modificado
    if [ "$base_name" != "$cleaned_name" ]; then
        mv -n "$original_name" "$dir_name/$cleaned_name" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Renombrado: '$original_name' -> '$dir_name/$cleaned_name'"
        else
            echo "Error al renombrar: '$original_name'"
        fi
    fi
}

# Recorrer el directorio y procesar nombres de archivos y carpetas
find "$base_path" -depth | while read -r path; do
    clean_name "$path"
done

#!/bin/bash

# Verificar si se proporcionó un directorio como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

# Directorio raíz donde buscar
DIRECTORIO="$1"

# Verificar si el directorio existe
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: El directorio '$DIRECTORIO' no existe."
    exit 1
fi

# Buscar y eliminar archivos con "_tmp" en el nombre, recorriendo subdirectorios
find "$DIRECTORIO" -type f -name '*_tmp*' -print -delete | while read -r archivo; do
    echo "Archivo eliminado: $archivo"
done

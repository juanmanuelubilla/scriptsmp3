#!/bin/bash

# Directorio en el que se realizará la búsqueda
directorio="$1"

# Buscar archivos OGG y comparar su contenido
fdupes -r -f "$directorio" | while read -r line; do
    echo "Duplicado encontrado:"
    echo "$line"
    echo "----"
done

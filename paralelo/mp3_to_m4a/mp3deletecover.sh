#!/bin/bash

# Directorio raíz desde donde se buscarán los archivos JPG
root_directory="$1"

# Función para eliminar archivos JPG
delete_jpg_files() {
    local dir="$1"
    local jpg_ext=".jpg"

    find "$dir" -type f -name "*$jpg_ext" -exec rm {} +
}

# Ejecutar la función para recorrer las carpetas y eliminar los archivos JPG
delete_jpg_files "$root_directory"

echo "Eliminación de archivos JPG completada."

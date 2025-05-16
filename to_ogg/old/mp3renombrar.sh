#!/bin/bash

directorio="$1"

# Función para eliminar caracteres sustitutos y otros no permitidos
sanitize_filename() {
    # Reemplaza caracteres Unicode no válidos (como \udcc2) y otros símbolos no permitidos con un guion bajo
    echo "$1" | iconv -f utf-8 -t utf-8//IGNORE | sed 's/[<>:"/\\|?*]//g'
}

# Buscar archivos con símbolos no permitidos en el nombre
find "$directorio" -type f -print0 | while IFS= read -r -d '' archivo; do
    # Obtener el nombre del archivo y la ruta del directorio
    nombre_archivo=$(basename "$archivo")
    directorio_archivo=$(dirname "$archivo")
    
    # Eliminar los símbolos no permitidos del nombre del archivo
    nuevo_nombre=$(sanitize_filename "$nombre_archivo")
    
    # Renombrar el archivo
    if [ "$nombre_archivo" != "$nuevo_nombre" ]; then
        mv "$archivo" "$directorio_archivo/$nuevo_nombre"
        echo "Archivo renombrado: $archivo -> $directorio_archivo/$nuevo_nombre"
    fi
done

# Buscar carpetas con símbolos no permitidos en el nombre
find "$directorio" -type d -print0 | while IFS= read -r -d '' archivo; do
    # Obtener el nombre del archivo y la ruta del directorio
    nombre_archivo=$(basename "$archivo")
    directorio_archivo=$(dirname "$archivo")
    
    # Eliminar los símbolos no permitidos del nombre del archivo
    nuevo_nombre=$(sanitize_filename "$nombre_archivo")
    
    # Renombrar el archivo
    if [ "$nombre_archivo" != "$nuevo_nombre" ]; then
        mv "$archivo" "$directorio_archivo/$nuevo_nombre"
        echo "Archivo renombrado: $archivo -> $directorio_archivo/$nuevo_nombre"
    fi
done

# Función para eliminar comillas simples en un nombre de archivo o carpeta
remove_quotes() {
    new_name=$(echo "$1" | tr "'" "´")
    mv "$1" "$new_name"
}

# Directorio base donde comenzará la búsqueda y reemplazo
base_dir="$1"

# Buscar y eliminar comillas simples en nombres de archivos y carpetas
find "$base_dir" -depth -name "*'*" | while read item; do
    remove_quotes "$item"
done


#!/bin/bash

# El directorio de entrada
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
    
    # Renombrar el archivo si es necesario
    if [ "$nombre_archivo" != "$nuevo_nombre" ]; then
        if ! mv "$archivo" "$directorio_archivo/$nuevo_nombre"; then
            echo "Error renombrando el archivo: $archivo"
        else
            echo "Archivo renombrado: $archivo -> $directorio_archivo/$nuevo_nombre"
        fi
    fi
done

# Buscar carpetas con símbolos no permitidos en el nombre
find "$directorio" -type d -print0 | while IFS= read -r -d '' archivo; do
    # Obtener el nombre del archivo y la ruta del directorio
    nombre_archivo=$(basename "$archivo")
    directorio_archivo=$(dirname "$archivo")
    
    # Eliminar los símbolos no permitidos del nombre del archivo
    nuevo_nombre=$(sanitize_filename "$nombre_archivo")
    
    # Renombrar el archivo si es necesario
    if [ "$nombre_archivo" != "$nuevo_nombre" ]; then
        if ! mv "$archivo" "$directorio_archivo/$nuevo_nombre"; then
            echo "Error renombrando la carpeta: $archivo"
        else
            echo "Carpeta renombrada: $archivo -> $directorio_archivo/$nuevo_nombre"
        fi
    fi
done

# Función para eliminar comillas simples en un nombre de archivo o carpeta
remove_quotes() {
    # Reemplaza comillas simples por acentos graves
    new_name=$(echo "$1" | sed "s/'/´/g")
    if ! mv "$1" "$new_name"; then
        echo "Error renombrando el archivo o carpeta: $1"
    else
        echo "Renombrado: $1 -> $new_name"
    fi
}

# Buscar y eliminar comillas simples en nombres de archivos y carpetas
find "$directorio" -depth -name "*'*" -print0 | while IFS= read -r -d '' item; do
    remove_quotes "$item"
done


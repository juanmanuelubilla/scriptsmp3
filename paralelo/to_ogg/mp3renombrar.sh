#!/bin/bash

# El directorio de entrada
directorio="$1"

# Asegurar que el entorno use UTF-8
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Función para eliminar caracteres no permitidos específicos
sanitize_filename() {
    # Reemplaza símbolos no permitidos con un guion bajo
    echo "$1" | sed 's/[<>:"/\\|?*]//g'
}

# Función para eliminar comillas simples en un nombre de archivo o carpeta
remove_quotes() {
    # Reemplaza comillas simples por acentos graves
    echo "$1" | sed "s/'/´/g"
}

# Función para eliminar iconos no imprimibles
remove_non_printable_chars() {
    # Elimina caracteres no imprimibles y de control (excepto los permitidos como espacio, tabulación, salto de línea)
    echo "$1" | tr -cd '\11\12\15\40-\176'
}

# Función para eliminar caracteres no deseados pero preservando las vocales acentuadas
remove_unwanted_characters() {
    # Reemplaza caracteres no deseados por guiones bajos, pero preserva los acentos
    echo "$1" | sed 's/[<>:"/\\|?*]//g'
}

# Función para procesar archivos y carpetas
process_files_and_dirs() {
    # Buscar archivos y carpetas con los símbolos no permitidos
    find "$directorio" -depth -print0 | while IFS= read -r -d '' item; do
        # Obtener el nombre del archivo o carpeta y la ruta del directorio
        nombre_item=$(basename "$item")
        directorio_item=$(dirname "$item")
        
        # Aplicar funciones de saneamiento
        nuevo_nombre=$(sanitize_filename "$nombre_item")
        nuevo_nombre=$(remove_quotes "$nuevo_nombre")
        nuevo_nombre=$(remove_unwanted_characters "$nuevo_nombre")
        nuevo_nombre=$(remove_non_printable_chars "$nuevo_nombre")
        
        # Renombrar si el nombre cambia
        if [ "$nombre_item" != "$nuevo_nombre" ]; then
            if ! mv "$item" "$directorio_item/$nuevo_nombre"; then
                echo "Error renombrando: $item"
            else
                echo "Renombrado: $item -> $directorio_item/$nuevo_nombre"
            fi
        fi
    done
}

# Llamar a la función para procesar los archivos y carpetas
process_files_and_dirs

#!/bin/bash

# Registrar tiempo de inicio
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|            ELIMINAR ARCHIVOS DE COVER           |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""



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

# Calcular y mostrar duración
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo -e "\033[1;36mEliminacion completada en ${minutes}m ${seconds}s usando $nproc procesos paralelos (bitrate: ${quality}).\033[0m"

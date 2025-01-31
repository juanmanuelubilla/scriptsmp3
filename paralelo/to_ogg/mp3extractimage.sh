#!/bin/bash

# Registrar el tiempo inicial
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|   EXTRACCIÓN DE COVER ALBUM DE LOS MP3...    |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

# Verifica si se proporcionó el path de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 <path>"
    exit 1
fi

# Directorio base
target_directory="$1"

# Verifica si el directorio existe
if [ ! -d "$target_directory" ]; then
    echo -e "\033[1;33mError: El directorio '$target_directory' no existe.\033[0m"
    exit 1
fi

# Buscar todos los archivos MP3 y contarlos
mapfile -t mp3_files < <(find "$target_directory" -type f -name "*.mp3")
total_files=${#mp3_files[@]}

# Si no hay archivos MP3, salir
if [ "$total_files" -eq 0 ]; then
    echo -e "\033[1;33mNo se encontraron archivos MP3 para procesar.\033[0m"
    exit 0
fi

## Función para extraer el cover art de un archivo MP3
#extract_cover() {
#    local mp3_file="$1"
#    local output_file="${mp3_file%.mp3}.jpg"
#
#    # Intentar extraer el cover art utilizando ffmpeg
#    if ! ffmpeg -i "${mp3_file}" -an -vcodec copy "${output_file}" < /dev/null 2> /dev/null; then
#        echo -e "\n\033[1;31mError al extraer el cover: ${mp3_file}\033[0m"
#    fi
#}

# Función para extraer el cover art de un archivo MP3
extract_cover() {
    local mp3_file="$1"
    local output_file="${mp3_file%.mp3}.jpg"

    # Intentar extraer el cover art utilizando ffmpeg
    ffmpeg -i "${mp3_file}" -an -vcodec copy "${output_file}" < /dev/null 2> /dev/null
}

# Procesar los archivos uno por uno con una barra de progreso
for i in "${!mp3_files[@]}"; do
    mp3_file="${mp3_files[$i]}"
    extract_cover "$mp3_file"
    
    # Calcular el porcentaje de progreso
    progress=$(( (i + 1) * 100 / total_files ))
    
    # Imprimir la barra de progreso con el contador a la derecha
    echo -ne "\r["
    for ((j = 0; j < progress / 2; j++)); do echo -n "#"; done
    for ((j = progress / 2; j < 50; j++)); do echo -n "-"; done
    printf "] %3d%% (%d/%d)" "$progress" "$((i + 1))" "$total_files"
done

echo ""

# Tiempo total de ejecución
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo "Duracion del proceso de extraccion: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
#echo ""

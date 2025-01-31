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

# Función para extraer el cover art de un archivo MP3
extract_cover() {
    local mp3_file="$1"
    local output_file="${mp3_file%.mp3}.jpg"

    # Intentar extraer el cover art utilizando ffmpeg
    if ! ffmpeg -i "${mp3_file}" -an -vcodec copy "${output_file}" < /dev/null 2> /dev/null; then
        # Si hay un error, imprimir en rojo
        echo -e "\033[1;31mError al extraer el cover para: ${mp3_file}\033[0m"
    else
        # Si se extrae con éxito, imprimir el nombre del archivo procesado
        echo "Cover extraído para: ${mp3_file}"
    fi
}

# Exportar la función para que xargs la use
export -f extract_cover

# Definir el número de hilos en paralelo (según los núcleos disponibles)
NUM_THREADS=$(nproc)

# Ejecutar el proceso en paralelo usando todos los núcleos disponibles
printf "Procesando %d archivos con %d hilos...\n\n" "$total_files" "$NUM_THREADS"

# Usar `xargs` para procesar los archivos en paralelo
printf "%s\0" "${mp3_files[@]}" | xargs -0 -n 1 -P "$NUM_THREADS" bash -c 'extract_cover "$@"' _

# Tiempo total de ejecución
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo "Tiempo total: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

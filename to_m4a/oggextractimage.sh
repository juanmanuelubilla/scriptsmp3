#!/bin/bash

# Registrar el tiempo de inicio
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m| EXTRAYENDO COVERS DE ARCHIVOS OGG CON FFmpeg... |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

# Verifica si se proporcionó el path de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

root_directory="$1"

# Verifica si el directorio existe
if [ ! -d "$root_directory" ]; then
    echo -e "\033[1;31mError: El directorio '$root_directory' no existe.\033[0m"
    exit 1
fi

# Obtener el número de núcleos disponibles
NUM_THREADS=$(nproc)

# Buscar archivos .ogg
mapfile -d '' files < <(find "$root_directory" -type f -name "*.ogg" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
    echo -e "\033[1;33mNo se encontraron archivos OGG.\033[0m"
    exit 0
fi

# Inicializar progreso
processed=0
bar_width=50
mutex="/tmp/cover_extract_lock.$$"
touch "$mutex"

# Archivos temporales para logs
SUCCESS_LOG=$(mktemp)
ERROR_LOG=$(mktemp)

# Barra de progreso
update_progress() {
    local p=$1
    local percent=$((p * 100 / total_files))
    local fill=$((p * bar_width / total_files))
    local bar=$(printf "%-${fill}s" "#" | tr ' ' '#')
    local space=$(printf "%-$((bar_width - fill))s")
    echo -ne "\r[${bar}${space}] ${percent}% (${p}/${total_files})"
}

# Función de extracción
extract_cover() {
    input_file="$1"
    output_file="${input_file%.ogg}.jpg"

    # Verificar si hay un stream de tipo attached_pic
    if ffmpeg -i "$input_file" 2>&1 | grep -q "Video: mjpeg"; then
        if ffmpeg -i "$input_file" -an -vcodec copy "$output_file" -y -loglevel error; then
            echo -e "\033[1;32m[OK] Cover extraído de: $input_file\033[0m" >> "$SUCCESS_LOG"
        else
            echo -e "\033[1;31m[ERROR] Fallo al guardar: $output_file\033[0m" >> "$ERROR_LOG"
        fi
    else
        echo -e "\033[1;33m[SKIP] No hay cover en: $input_file\033[0m" >> "$ERROR_LOG"
    fi

    {
        flock 200
        ((processed++))
        update_progress "$processed"
    } 200>"$mutex"
}

export -f extract_cover
export total_files processed bar_width mutex SUCCESS_LOG ERROR_LOG
export -f update_progress

# Procesar en paralelo
printf "%s\0" "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" bash -c 'extract_cover "$0"'

# Finalizar barra
echo ""

# Mostrar resultados
echo ""
echo -e "\033[1;36mResumen de extracción:\033[0m"
cat "$SUCCESS_LOG"
cat "$ERROR_LOG"

# Limpiar
rm -f "$mutex" "$SUCCESS_LOG" "$ERROR_LOG"

# Tiempo total
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))
echo ""
echo "Extracción de covers completada en ${minutes}m ${seconds}s"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

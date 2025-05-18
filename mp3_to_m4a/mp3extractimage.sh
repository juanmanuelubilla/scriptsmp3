#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|        EXTRACCION DE COVERS EN MP3...        |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

if [ -z "$1" ]; then
    echo "Uso: $0 <path>"
    exit 1
fi

base_path="$1"

if [ ! -d "$base_path" ]; then
    echo -e "\033[1;33mError: El directorio '$base_path' no existe.\033[0m"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo -e "\033[1;31mError: ffmpeg no está instalado. Instálalo e intenta de nuevo.\033[0m"
    exit 1
fi

NUM_THREADS=$(nproc)

process_directory() {
    local dir="$1"
    local ext=".mp3"

    find "$dir" -type f -name "*$ext" -print0 | \
    while IFS= read -r -d '' input_file; do
        (
            output_file="${input_file%.mp3}.jpg"
            ffmpeg -i "$input_file" -an -vcodec copy "$output_file" 2>/dev/null

            if [ -s "$output_file" ]; then
                echo "Cover extraído de: $input_file"
            else
                [ -f "$output_file" ] && rm "$output_file"
                echo -e "\033[1;31mNo se encontró cover en: $input_file\033[0m"
            fi
        ) &

        while [ "$(jobs -r | wc -l)" -ge "$NUM_THREADS" ]; do
            sleep 0.1
        done
    done

    wait
}

process_directory "$base_path"

echo "Extracción de covers completada."

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "Duración del proceso de extracción: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

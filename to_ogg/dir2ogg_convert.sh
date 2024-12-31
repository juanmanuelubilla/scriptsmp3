#!/bin/bash

# Directorio de entrada
INPUT_DIR="$1"

# Validar si el directorio de entrada fue especificado
if [[ -z "$INPUT_DIR" ]]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

# Validar si el directorio de entrada existe
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: El directorio '$INPUT_DIR' no existe."
    exit 1
fi

# Verificar cuántos hilos están disponibles
AVAILABLE_THREADS=$(mpstat -P ALL 1 1 | awk '/^Average:/ && $2 ~ /^[0-9]+$/ {if ($NF > 20) count++} END {print count}')

# Usar al menos un hilo si no se detectan disponibles
if [[ -z "$AVAILABLE_THREADS" || "$AVAILABLE_THREADS" -eq 0 ]]; then
    AVAILABLE_THREADS=1
fi

echo "Hilos disponibles para procesamiento: $AVAILABLE_THREADS"

# Crear una lista de archivos a procesar
FILES=($(find "$INPUT_DIR" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.m4a" -o -iname "*.wma" -o -iname "*.aac" \)))

# Total de archivos
TOTAL_FILES=${#FILES[@]}

if [[ "$TOTAL_FILES" -eq 0 ]]; then
    echo "No se encontraron archivos de audio compatibles en '$INPUT_DIR'."
    exit 0
fi

echo "Archivos encontrados: $TOTAL_FILES"

# Función para procesar un archivo
process_file() {
    local file="$1"
    echo "Procesando: $file"
    dir2ogg -d "$(dirname "$file")" -r -q 4.50 --delete-input "$file"
    if [[ $? -eq 0 ]]; then
        echo "Archivo convertido con éxito: $file"
    else
        echo "Error al convertir: $file"
    fi
}

# Exportar la función para que esté disponible en hilos paralelos
export -f process_file

# Procesar los archivos en paralelo
echo "Iniciando la conversión en paralelo con $AVAILABLE_THREADS hilos..."
printf "%s\n" "${FILES[@]}" | xargs -n 1 -P "$AVAILABLE_THREADS" bash -c 'process_file "$@"' _

echo "Conversión completada."


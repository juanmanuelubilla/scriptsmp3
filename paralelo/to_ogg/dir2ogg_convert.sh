#!/bin/bash

# Configuración
NUM_THREADS=$(nproc) # Detectar núcleos disponibles
TEMP_DIR="/tmp/dir2ogg" # Directorio temporal

# Crear directorio temporal
mkdir -p "$TEMP_DIR" || { echo "No se pudo crear el directorio temporal"; exit 1; }

# Validar argumentos
if [ $# -ne 1 ]; then
    echo "Uso: $0 <directorio_de_entrada>"
    exit 1
fi

INPUT_DIR="$1"

# Verificar directorio
if [ ! -d "$INPUT_DIR" ]; then
    echo "Directorio no encontrado: $INPUT_DIR"
    exit 1
fi

# Buscar archivos compatibles con dir2ogg
echo "Buscando archivos de audio en: $INPUT_DIR"
find "$INPUT_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' -o -iname '*.m4a' \) > "$TEMP_DIR/files.txt"

# Verificar resultados
if [ ! -s "$TEMP_DIR/files.txt" ]; then
    echo "No se encontraron archivos de audio compatibles."
    exit 1
fi

# Función para convertir archivos con dir2ogg
convert_file() {
    INPUT_FILE="$1"
    echo "Procesando: $INPUT_FILE"
    # Usar los parámetros que mencionaste para dir2ogg
    if dir2ogg -r -q 4.50 --delete-input "$INPUT_FILE"; then
        echo "Conversión exitosa: $INPUT_FILE"
    else
        echo "Error al convertir: $INPUT_FILE"
    fi
}

export -f convert_file

# Procesar archivos en paralelo
echo "Iniciando conversión en paralelo con $NUM_THREADS hilos..."
xargs -0 -a <(tr '\n' '\0' < "$TEMP_DIR/files.txt") -n 1 -P "$NUM_THREADS" bash -c 'convert_file "$@"' _

echo "Conversión completada."


#!/bin/bash

# Directorio base
DIRECTORIO_BASE="$1"

# Validar que se haya proporcionado un directorio
if [ -z "$DIRECTORIO_BASE" ]; then
    echo "Uso: $0 <directorio_base>"
    exit 1
fi

# Número de hilos disponibles (núcleos de la CPU)
HILOS=$(nproc)

# Encuentra archivos MP3 y los procesa en paralelo con xargs
find "$DIRECTORIO_BASE" -type f -name "*.mp3" | xargs -P "$HILOS" -I {} bash -c '
    archivo_mp3="{}"
    archivo_sin_extension="${archivo_mp3%.*}"
    archivo_m4a="${archivo_sin_extension}.m4a"

    # Verifica si el archivo M4A ya existe
    if [ -f "$archivo_m4a" ]; then
        echo "El archivo ya existe, omitiendo: $archivo_m4a"
        exit 0
    fi

    # Convierte el archivo MP3 a M4A asegurando códec AAC y formato correcto
    ffmpeg -i "$archivo_mp3" -vn -c:a aac -b:a 96k -movflags +faststart "$archivo_m4a" -loglevel error

    # Verifica si la conversión fue exitosa
    if [ $? -eq 0 ]; then
        echo "Conversión exitosa: $archivo_mp3 -> $archivo_m4a"
    else
        echo "Error al convertir: $archivo_mp3"
        # exit 1
    fi
'

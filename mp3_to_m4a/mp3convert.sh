#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|       EXTRACCIÓN DE COVERS EN AUDIO...       |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

# Validar que se haya proporcionado al menos un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio_base> [bitrate]"
    exit 1
fi

# Directorio base
DIRECTORIO_BASE="$1"

# Bitrate (segundo parámetro, por defecto 96k)
BITRATE="${2:-96k}"

# Validar que el directorio exista
if [ ! -d "$DIRECTORIO_BASE" ]; then
    echo -e "\033[1;33mError: El directorio '$DIRECTORIO_BASE' no existe.\033[0m"
    exit 1
fi

# Verificar que ffmpeg esté instalado
if ! command -v ffmpeg &> /dev/null; then
    echo -e "\033[1;31mError: ffmpeg no está instalado. Instálalo e intenta de nuevo.\033[0m"
    exit 1
fi

# Número de hilos disponibles (núcleos de la CPU)
HILOS=$(nproc)

# Encuentra archivos de audio comunes y los procesa en paralelo
find "$DIRECTORIO_BASE" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.wma" -o -iname "*.m4a" \) | \
xargs -P "$HILOS" -I {} bash -c '
    archivo_audio="{}"
    archivo_sin_extension="${archivo_audio%.*}"
    archivo_m4a="${archivo_sin_extension}.m4a"
    bitrate="'"$BITRATE"'"

    # Verifica si el archivo M4A ya existe
    if [ -f "$archivo_m4a" ]; then
        echo "El archivo ya existe, omitiendo: $archivo_m4a"
        exit 0
    fi

    # Convierte el archivo de audio a M4A con códec AAC y el bitrate proporcionado
    ffmpeg -i "$archivo_audio" -vn -c:a aac -b:a "$bitrate" -movflags +faststart "$archivo_m4a" -loglevel error

    if [ $? -eq 0 ]; then
        echo "Conversión exitosa: $archivo_audio -> $archivo_m4a"
    else
        echo -e "\033[1;31mError al convertir: $archivo_audio\033[0m"
    fi
'

echo ""
echo "Conversión de archivos completada."

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "Duración del proceso: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

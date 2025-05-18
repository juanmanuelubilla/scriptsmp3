#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|       CONVERSIÓN DE AUDIO A M4A (FAAC)       |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

# Validar que se haya proporcionado al menos un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio_base> [bitrate]"
    exit 1
fi

# Directorio base
DIRECTORIO_BASE="$1"

# Bitrate (segundo parámetro, por defecto 128)
BITRATE="${2:-128}"

# Validar que el directorio exista
if [ ! -d "$DIRECTORIO_BASE" ]; then
    echo -e "\033[1;33mError: El directorio '$DIRECTORIO_BASE' no existe.\033[0m"
    exit 1
fi

# Función para instalar paquetes si no están disponibles
instalar_si_falta() {
    comando="$1"
    paquete="$2"
    if ! command -v "$comando" &>/dev/null; then
        echo -e "\033[1;34mInstalando $paquete...\033[0m"
        apt-get update && apt-get install -y "$paquete"
    fi
}

# Verificar e instalar dependencias
instalar_si_falta faac faac
instalar_si_falta ffmpeg ffmpeg
instalar_si_falta oggdec vorbis-tools

# Número de hilos disponibles (núcleos de la CPU)
HILOS=$(nproc)

# Función para convertir un archivo de audio a M4A usando faac
convertir_audio() {
    archivo="$1"
    extension="${archivo##*.}"
    base="${archivo%.*}"
    destino="${base}.m4a"

    # Evita sobrescribir si ya existe
    if [ -f "$destino" ]; then
        echo -e "\033[1;33m[OMITIDO] Ya existe: $destino\033[0m"
        return
    fi

    case "${extension,,}" in
        ogg)
            oggdec -o - "$archivo" 2>/dev/null | faac -b "$BITRATE" -o "$destino" - >/dev/null 2>&1
            ;;
        mp3|flac|wav|aac|wma|m4a)
            ffmpeg -i "$archivo" -f wav - 2>/dev/null | faac -b "$BITRATE" -o "$destino" - >/dev/null 2>&1
            ;;
        *)
            echo -e "\033[1;33m[SKIP] Formato no compatible: $archivo\033[0m"
            return
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[OK] Conversión exitosa: $archivo → $destino\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Falló la conversión: $archivo\033[0m"
    fi
}

export -f convertir_audio
export BITRATE

# Buscar y procesar todos los archivos de audio en paralelo
find "$DIRECTORIO_BASE" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.wma" -o -iname "*.m4a" \) \
    | xargs -P "$HILOS" -I {} bash -c 'convertir_audio "$@"' _ {}

echo ""
echo "Conversión de archivos completada."

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "Duración del proceso: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

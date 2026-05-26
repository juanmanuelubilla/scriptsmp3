#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|       CONVERSIÓN DE AUDIO A M4A (ffmpeg)      |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

if [ -z "$1" ]; then
    echo "Uso: $0 <directorio_base> [bitrate_kbps]"
    exit 1
fi

DIRECTORIO_BASE="$1"
BITRATE="${2:-128}"

if [ ! -d "$DIRECTORIO_BASE" ]; then
    echo -e "\033[1;33mError: El directorio '$DIRECTORIO_BASE' no existe.\033[0m"
    exit 1
fi

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/install_deps.sh
source "$_REPO_ROOT/lib/install_deps.sh"
# shellcheck source=lib/convert_m4a.sh
source "$_REPO_ROOT/lib/convert_m4a.sh"

require_command ffmpeg ffmpeg || exit 1

HILOS=$(nproc)

convertir_audio() {
    local archivo="$1"
    local destino="${archivo%.*}.m4a"

    case "${archivo,,}" in
        *.mp3|*.ogg|*.flac|*.wav|*.aac|*.wma|*.m4a) ;;
        *) echo -e "\033[1;33m[SKIP] Formato no compatible: $archivo\033[0m"; return ;;
    esac

    if [ -f "$destino" ]; then
        echo -e "\033[1;33m[OMITIDO] Ya existe: $destino\033[0m"
        return
    fi

    if ffmpeg_to_m4a "$archivo" "$destino" "$BITRATE"; then
        echo -e "\033[1;32m[OK] Conversión exitosa: $archivo → $destino\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Falló la conversión: $archivo\033[0m"
    fi
}

export -f convertir_audio
export -f ffmpeg_to_m4a
export BITRATE

find "$DIRECTORIO_BASE" -type f \( \
    -iname "*.mp3" -o -iname "*.wav" -o -iname "*.flac" -o \
    -iname "*.ogg" -o -iname "*.aac" -o -iname "*.wma" -o -iname "*.m4a" \
\) -print0 | xargs -0 -n 1 -P "$HILOS" -I {} bash -c 'convertir_audio "$1"' _ {}

echo ""
echo "Conversión de archivos completada."

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "Duración del proceso: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

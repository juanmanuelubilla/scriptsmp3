#!/bin/bash
# Conversión OGG → MP3 (carátulas y metadata)

clear

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root: sudo ./convertmp3.sh <directorio> [bitrate]"
  exit 1
fi

start_time=$(date +%s)

if [ -z "$1" ]; then
  echo "Uso: $0 <directorio> [bitrate_kbps]"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "El directorio proporcionado no es válido: $1"
  exit 1
fi

DIRECTORIO="$1"
BITRATE="${2:-128}"

carpetas=$(find "$DIRECTORIO" -type d | wc -l)
archivos=$(find "$DIRECTORIO" -type f | wc -l)

_REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/install_deps.sh
source "$_REPO_ROOT/lib/install_deps.sh"
# shellcheck source=lib/ui_common.sh
source "$_REPO_ROOT/lib/ui_common.sh"
install_deps_ogg_to_mp3 >/dev/null 2>&1
require_whiptail || exit 1

mensaje=$(whiptail_msg "Ruta: $DIRECTORIO\nCarpetas: $((carpetas - 1))\nArchivos: $archivos\nBitrate MP3: ${BITRATE} kbps\n\nEspacio = marcar/desmarcar, Enter = confirmar, Esc = cancelar")

opciones=$(whiptail --title "CONVERSIÓN DE OGG A MP3" --checklist "$mensaje" 22 82 7 \
  "1" "Renombrar archivos con caracteres raros" ON \
  "2" "Extraer covers de archivos OGG" ON \
  "3" "Convertir archivos a MP3" ON \
  "4" "Importar covers a MP3" ON \
  "5" "Importar metadata a MP3" ON \
  "6" "Borrar archivos JPG (covers)" ON \
  "7" "Eliminar archivos .OGG (confirmación)" OFF 3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
  echo "Operación cancelada."
  exit 1
fi

readarray -t opciones_array < <(whiptail_parse_checklist "$opciones")

eliminar_ogg() {
  ogg_files=$(find "$DIRECTORIO" -type f -name "*.ogg")
  if [ -z "$ogg_files" ]; then
    echo "No se encontraron archivos .ogg."
    return
  fi
  echo "$ogg_files"
  echo -e "\e[31m¡ATENCIÓN! Se eliminarán todos los .ogg en '$DIRECTORIO'.\e[0m"
  read -p "¿Continuar? (y/n): " respuesta
  if [[ "$respuesta" =~ ^[Yy]$ ]]; then
    find "$DIRECTORIO" -type f -name "*.ogg" -print0 | while IFS= read -r -d '' archivo; do
      rm "$archivo" && echo "Eliminado: $archivo"
    done
  fi
}

for opcion in "${opciones_array[@]}"; do
  case $opcion in
    1) ./to_ogg/mp3renombrar.sh "$DIRECTORIO" ;;
    2) ./to_mp3/oggextractimage.sh "$DIRECTORIO" ;;
    3) ./to_mp3/oggconvert.sh "$DIRECTORIO" "$BITRATE" ;;
    4) ./to_mp3/oggimportimage.sh "$DIRECTORIO" ;;
    5) ./to_mp3/oggimportmetadata.sh "$DIRECTORIO" ;;
    6) ./to_mp3/oggdeletecover.sh "$DIRECTORIO" ;;
    7) eliminar_ogg ;;
    *) echo "Opción inválida: $opcion" ;;
  esac
done

end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)
echo ""
echo -e "\033[1;36mEl script se completó en $execution_time segundos (~$execution_time_hours h).\033[0m"

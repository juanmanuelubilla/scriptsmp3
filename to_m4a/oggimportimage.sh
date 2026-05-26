#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|       IMPORTANDO COVERS A ARCHIVOS M4A          |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/install_deps.sh
source "$_REPO_ROOT/lib/install_deps.sh"
# shellcheck source=lib/ui_common.sh
source "$_REPO_ROOT/lib/ui_common.sh"

if ! require_command AtomicParsley atomicparsley; then
  echo "Error: AtomicParsley no está disponible. Instala: apt install atomicparsley"
  exit 1
fi

ruta_raiz="$1"

if [ ! -d "$ruta_raiz" ]; then
  echo -e "\033[1;31mError: El directorio '$ruta_raiz' no existe.\033[0m"
  exit 1
fi

NUM_THREADS=$(nproc)
mutex="/tmp/import_cover_lock.$$"
count_file="/tmp/import_cover_count.$$"
touch "$mutex"

DETAIL_LOG=$(mktemp)

import_cover() {
  local archivo_m4a="$1"
  local nombre_archivo_m4a carpeta_m4a caratula_con_mismo_nombre

  nombre_archivo_m4a=$(basename "$archivo_m4a")
  carpeta_m4a=$(dirname "$archivo_m4a")

  caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.jpg"
  [ ! -f "$caratula_con_mismo_nombre" ] && caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.png"
  [ ! -f "$caratula_con_mismo_nombre" ] && caratula_con_mismo_nombre="$carpeta_m4a/cover.jpg"
  [ ! -f "$caratula_con_mismo_nombre" ] && caratula_con_mismo_nombre="$carpeta_m4a/cover.png"

  if [ -f "$caratula_con_mismo_nombre" ]; then
    if AtomicParsley "$archivo_m4a" --artwork "$caratula_con_mismo_nombre" --overWrite &>/dev/null; then
      echo -e "\033[1;32m[OK] Cover importado en: $archivo_m4a\033[0m" >>"$DETAIL_LOG"
    else
      echo -e "\033[1;31m[ERROR] Falló importación en: $archivo_m4a\033[0m" >>"$DETAIL_LOG"
    fi
  else
    echo -e "\033[1;33m[WARN] No se encontró carátula para: $archivo_m4a\033[0m" >>"$DETAIL_LOG"
  fi

  ui_progress_file_tick "$count_file" "$total_files" "$mutex"
}

mapfile -d '' files < <(find "$ruta_raiz" -type f -name "*.m4a" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
  echo -e "\033[1;33mNo se encontraron archivos M4A en el directorio.\033[0m"
  exit 0
fi

ui_progress_file_init "$count_file"

export -f import_cover
export -f ui_progress_file_tick ui_bar_render
export total_files mutex count_file DETAIL_LOG

printf '%s\0' "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" -I {} bash -c 'import_cover "$1"' _ {}

ui_bar_finish
echo ""
[ -s "$DETAIL_LOG" ] && cat "$DETAIL_LOG"
rm -f "$DETAIL_LOG" "$mutex" "$count_file"

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo -e "\033[1;36mImportación completada en ${minutes}m ${seconds}s.\033[0m"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

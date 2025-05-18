#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|       IMPORTANDO COVERS DEL ARCHIVO OGG         |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

# Función para instalar AtomicParsley si no está instalado
instalar_atomicparsley() {
  echo "Instalando AtomicParsley con apt..."
  apt update && apt install -y atomicparsley
}

# Verificar si AtomicParsley está instalado, de lo contrario, instalarlo
if ! command -v AtomicParsley &> /dev/null; then
  echo "AtomicParsley no está instalado. Intentando instalarlo..."
  instalar_atomicparsley
  if ! command -v AtomicParsley &> /dev/null; then
    echo "Error: No se pudo instalar AtomicParsley."
    exit 1
  fi
fi

ruta_raiz="$1"

if [ ! -d "$ruta_raiz" ]; then
  echo -e "\033[1;31mError: El directorio '$ruta_raiz' no existe.\033[0m"
  exit 1
fi

NUM_THREADS=$(nproc)
bar_width=50
mutex="/tmp/import_cover_lock.$$"
touch "$mutex"
processed=0

# Función para actualizar barra de progreso
update_progress() {
    local p=$1
    local total=$2
    local percent=$(( p * 100 / total ))
    local fill=$(( p * bar_width / total ))
    local bar=$(printf "%-${fill}s" "#" | tr ' ' '#')
    local space=$(printf "%-$((bar_width - fill))s")
    echo -ne "\r[${bar}${space}] ${percent}% (${p}/${total})"
}

# Función que intenta agregar carátula a un archivo M4A y reporta resultado
import_cover() {
  local archivo_m4a="$1"
  local nombre_archivo_m4a=$(basename "$archivo_m4a")
  local carpeta_m4a=$(dirname "$archivo_m4a")
  
  # Buscar carátula
  local caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.jpg"
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.png"
  fi
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_m4a/cover.jpg"
    if [ ! -f "$caratula_con_mismo_nombre" ]; then
      caratula_con_mismo_nombre="$carpeta_m4a/cover.png"
    fi
  fi

  if [ -f "$caratula_con_mismo_nombre" ]; then
    if AtomicParsley "$archivo_m4a" --artwork "$caratula_con_mismo_nombre" --overWrite &>/dev/null; then
      echo -e "\033[1;32m[OK] Cover importado en: $archivo_m4a\033[0m"
    else
      echo -e "\033[1;31m[ERROR] Falló importación en: $archivo_m4a\033[0m"
    fi
  else
    echo -e "\033[1;33m[WARN] No se encontró carátula para: $archivo_m4a\033[0m"
  fi

  # Incrementar contador y actualizar barra de progreso sincronizado
  {
    flock 200
    ((processed++))
    update_progress "$processed" "$total_files"
  } 200>"$mutex"
}

export -f import_cover
export -f update_progress
export bar_width mutex
export -n processed
export total_files

# Leer todos los archivos .m4a en el directorio raíz y subdirectorios
mapfile -d '' files < <(find "$ruta_raiz" -type f -name "*.m4a" -print0)
total_files=${#files[@]}

if [ "$total_files" -eq 0 ]; then
  echo -e "\033[1;33mNo se encontraron archivos M4A en el directorio.\033[0m"
  exit 0
fi

# Procesar en paralelo con xargs según núcleos
printf "%s\0" "${files[@]}" | xargs -0 -n1 -P"$NUM_THREADS" bash -c 'import_cover "$0"'

echo -e "\n"

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo -e "\033[1;36mImportación completada en ${minutes}m ${seconds}s.\033[0m"
echo -e "\033[1;36m+-------------------------+\033[0m"
echo ""

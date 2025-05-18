#!/bin/bash

start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|       IMPORTACION DE COVERS EN AUDIO...       |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

if [ -z "$1" ]; then
    echo -e "\033[1;31mUso: $0 <directorio>\033[0m"
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
    echo -e "\033[1;31mError: No se pudo instalar AtomicParsley.\033[0m"
    exit 1
  fi
fi

# Función para agregar carátula a un archivo M4A
agregar_caratula() {
  archivo_m4a="$1"
  archivo_caratula="$2"

  AtomicParsley "$archivo_m4a" --artwork "$archivo_caratula" --overWrite > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo -e "\033[1;32m✔ Carátula agregada:\033[0m $archivo_m4a"
  else
    echo -e "\033[1;31m✘ Error al agregar carátula:\033[0m $archivo_m4a"
  fi
}

# Recorrer los archivos M4A en todas las carpetas y subcarpetas
while IFS= read -r -d '' archivo_m4a; do
  nombre_archivo_m4a=$(basename "$archivo_m4a")
  carpeta_m4a=$(dirname "$archivo_m4a")

  caratula="$carpeta_m4a/${nombre_archivo_m4a%.*}.jpg"
  [ ! -f "$caratula" ] && caratula="$carpeta_m4a/${nombre_archivo_m4a%.*}.png"
  [ ! -f "$caratula" ] && caratula="$carpeta_m4a/cover.jpg"
  [ ! -f "$caratula" ] && caratula="$carpeta_m4a/cover.png"

  if [ -f "$caratula" ]; then
    agregar_caratula "$archivo_m4a" "$caratula"
  else
    echo -e "\033[1;31m✘ No se encontró carátula para:\033[0m $archivo_m4a"
  fi

done < <(find "$base_path" -type f -name "*.m4a" -print0)

echo ""
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|   Importación de covers finalizada en: ${minutes}m ${seconds}s   |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

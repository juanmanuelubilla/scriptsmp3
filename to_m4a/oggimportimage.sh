#!/bin/bash

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

# Ruta a la carpeta raíz donde se encuentran los archivos M4A y las carátulas
ruta_raiz="$1"

# Función para agregar carátula a un archivo M4A
agregar_caratula() {
  archivo_m4a="$1"
  archivo_caratula="$2"

  AtomicParsley "$archivo_m4a" --artwork "$archivo_caratula" --overWrite
}

# Recorrer los archivos M4A en todas las carpetas y subcarpetas
while IFS= read -r -d '' archivo_m4a; do
  # Obtener el nombre del archivo M4A sin la ruta
  nombre_archivo_m4a=$(basename "$archivo_m4a")

  # Carpeta que contiene el archivo M4A (sin el nombre del archivo)
  carpeta_m4a=$(dirname "$archivo_m4a")

  # Buscar una carátula con el mismo nombre del archivo M4A
  caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.jpg"

  # Si no se encuentra la carátula con el mismo nombre en formato jpg, busca en formato png
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_m4a/${nombre_archivo_m4a%.*}.png"
  fi

  # Si no se encuentra la carátula con el mismo nombre, usar "cover.jpg" o "cover.png"
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_m4a/cover.jpg"
    if [ ! -f "$caratula_con_mismo_nombre" ]; then
      caratula_con_mismo_nombre="$carpeta_m4a/cover.png"
    fi
  fi

  # Agregar la carátula solo si se encontró
  if [ -f "$caratula_con_mismo_nombre" ]; then
    agregar_caratula "$archivo_m4a" "$caratula_con_mismo_nombre"
  else
    echo "Advertencia: No se encontró carátula para $archivo_m4a"
  fi

done < <(find "$ruta_raiz" -type f -name "*.m4a" -print0)

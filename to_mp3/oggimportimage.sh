#!/bin/bash

# Ruta a la carpeta raíz donde se encuentran los archivos MP3 y las carátulas
ruta_raiz="$1"

# Función para agregar carátula a un archivo MP3
agregar_caratula() {
  archivo_mp3="$1"
  archivo_caratula="$2"

  # Usar eyeD3 para agregar la carátula
  eyeD3 --add-image "$archivo_caratula:FRONT_COVER" "$archivo_mp3"
}

# Función para obtener el archivo de carátula correspondiente
obtener_caratula() {
  archivo_mp3="$1"
  nombre_archivo_mp3=$(basename "$archivo_mp3")
  carpeta_mp3=$(dirname "$archivo_mp3")

  # Buscar una carátula con el mismo nombre del archivo MP3
  caratula_con_mismo_nombre="$carpeta_mp3/${nombre_archivo_mp3%.*}.jpg"

  # Si no se encuentra la carátula con el mismo nombre en formato jpg, busca en formato png
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_mp3/${nombre_archivo_mp3%.*}.png"
  fi

  # Si no se encuentra la carátula con el mismo nombre, usar "cover.jpg" o "cover.png"
  if [ ! -f "$caratula_con_mismo_nombre" ]; then
    caratula_con_mismo_nombre="$carpeta_mp3/cover.jpg"
    if [ ! -f "$caratula_con_mismo_nombre" ]; then
      caratula_con_mismo_nombre="$carpeta_mp3/cover.png"
    fi
  fi

  # Si se encontró una carátula, llamar a la función para agregarla
  if [ -f "$caratula_con_mismo_nombre" ]; then
    agregar_caratula "$archivo_mp3" "$caratula_con_mismo_nombre"
  else
    echo "Advertencia: No se encontró carátula para $archivo_mp3"
  fi
}

export -f agregar_caratula
export -f obtener_caratula

# Encontrar los archivos MP3 y procesarlos en paralelo con xargs
find "$ruta_raiz" -type f -name "*.mp3" -print0 | xargs -0 -n 1 -P $(nproc) -I {} bash -c 'obtener_caratula "{}"'

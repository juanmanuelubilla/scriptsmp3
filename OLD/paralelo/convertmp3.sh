#!/bin/bash

# Registrar el tiempo inicial
start_time=$(date +%s)

# Verificar que se haya proporcionado un argumento
if [ -z "$1" ]; then
  echo "Por favor, proporciona un directorio."
  exit 1
fi

# Verificar si el argumento es un directorio válido
if [ ! -d "$1" ]; then
  echo "El argumento proporcionado no es un directorio válido."
  exit 1
fi

# Contar carpetas y archivos en el directorio proporcionado
carpetas=$(find "$1" -type d | wc -l)
archivos=$(find "$1" -type f | wc -l)

# Imprimir el resumen con saltos de línea
echo -e "CARPETAS: $((carpetas - 1))\nARCHIVOS: $archivos\n\n"

#RUTA ACTUAL
ruta_actual=$(pwd)

#IMPRIMO LA RUTA DONDE SE TRABAJA
echo "LA RUTA ESPECIFICADA ES: $1"
echo "LA CALIDAD ESPECIFICADA PARA LOS M4A es $2"

#INSTALO LO QUE NECESITO
sudo apt-get install ffmpeg lame vorbis-tools atomicparsley mediainfo fdkaac parallel eyed3 id3v2 -y

# EJECUTO ARCHIVO BASH PARA RENOMBRAR ARCHIVOS QUE TIENEN CARACTERES RAROS
sudo ./to_ogg/mp3renombrar.sh "$1"

#EXTRAIGO LOS COVER DE LOS ARCHIVOS OGG
sudo ./to_mp3/oggextractimage.sh "$1"

#CONVIERTO LOS ARCHIVOS A M4A
sudo ./to_mp3/oggconvert.sh "$1" 128

#IMPORTO LOS COVER A LOS M4A
sudo ./to_mp3/oggimportimage.sh "$1"

#IMPORTO LA METADATA
sudo ./to_mp3/oggimportmetadata.sh "$1"

#BORRO TODOS LOS JPG
sudo ./to_mp3/oggdeletecover.sh "$1"


#AGREGO ACA EL SCRIPT DE BORRADO OGG PARA NO HACER CAGADAS...
# Verificar si se ha pasado un argumento (directorio)
if [ -z "$1" ]; then
  echo "DEBES PROPORCIONAR UN DIRECTORIO COMO PARÁMETRO"
  exit 1
fi

# Directorio proporcionado como argumento
root_directory="$1"

# Verificar si el directorio existe
if [ ! -d "$root_directory" ]; then
  echo "EL DIRECTORIO '$root_directory' NO EXISTE"
  exit 1
fi

find "$root_directory" -type d

# Buscar todos los archivos .ogg
ogg_files=$(find "$root_directory" -type f -name "*.ogg")

# Si no se encontraron archivos .ogg
if [ -z "$ogg_files" ]; then
  echo "NO SE ENCONTRARON ARCHIVOS .OGG EN '$root_directory'"
  exit 0
fi

# Mostrar los archivos encontrados antes de eliminar
echo "Se encontraron los siguientes archivos .OGG que serán eliminados:"
echo "$ogg_files"

# Eliminar los archivos .ogg
echo "ELIMINANDO LOS ARCHIVOS .OGG..."
while IFS= read -r -d '' archivo; do
  rm "$archivo" && echo "ELIMINADO: $archivo"
done < <(find "$root_directory" -type f -name "*.ogg" -print0)

echo "ELIMINACIÓN COMPLETA."



# Registrar el tiempo final
end_time=$(date +%s)

# Calcular y mostrar el tiempo total de ejecución
execution_time=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)
echo -e "\033[1;36mEl script se completó en $execution_time segundos.\033[0m"
echo -e "\033[1;36mEsto equivale a aproximadamente $execution_time_hours horas.\033[0m"

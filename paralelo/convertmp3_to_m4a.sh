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
sudo apt-get install ffmpeg faac vorbis-tools atomicparsley mediainfo fdkaac parallel -y

# EJECUTO ARCHIVO BASH PARA RENOMBRAR ARCHIVOS QUE TIENEN CARACTERES RAROS
sudo ./to_ogg/mp3renombrar.sh "$1"

#EXTRAIGO LOS COVER DE LOS ARCHIVOS OGG
sudo ./mp3_to_m4a/mp3extractimage.sh "$1"

#CONVIERTO LOS ARCHIVOS A M4A
sudo ./mp3_to_m4a/mp3convert.sh "$1" 96

#IMPORTO LOS COVER A LOS M4A
sudo ./mp3_to_m4a/mp3importimage.sh "$1"

#IMPORTO LA METADATA
#sudo ./mp3_to_m4a/mp3importmetadata.sh "$1"

#BORRO TODOS LOS JPG
sudo ./mp3_to_m4a/mp3deletecover.sh "$1"


#AGREGO ACA EL SCRIPT DE BORRADO OGG PARA NO HACER CAGADAS...

#!/bin/bash

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

# Buscar todos los archivos .ogg
ogg_files=$(find "$root_directory" -type f -name "*.mp3")

# Si no se encontraron archivos .ogg
if [ -z "$ogg_files" ]; then
  echo "NO SE ENCONTRARON ARCHIVOS .MP3 EN '$root_directory'"
  exit 0
fi

# Mostrar los archivos encontrados antes de eliminar
echo "Se encontraron los siguientes archivos .MP3:"
echo "$ogg_files"

# Mostrar el mensaje de confirmación
echo -e "\e[31m¡¡¡ATENCIÓN!!! ESTÁS A PUNTO DE ELIMINAR LOS ARCHIVOS .MP3 EN '$root_directory'\e[0m"
echo "¿DESEAS CONTINUAR? (y/n): "
read respuesta

# Si la respuesta es sí, eliminar los archivos .ogg
if [[ "$respuesta" =~ ^[Yy]$ ]]; then
  echo "ELIMINANDO LOS ARCHIVOS .MP3..."
  # Recorrer los archivos encontrados
  while IFS= read -r -d '' archivo; do
    rm "$archivo" && echo "ELIMINADO: $archivo"
  done < <(find "$root_directory" -type f -name "*.mp3" -print0)
  
  echo "ELIMINACIÓN COMPLETA."
else
  echo "NO SE ELIMINÓ NINGÚN ARCHIVO."
fi


# Registrar el tiempo final
end_time=$(date +%s)

# Calcular y mostrar el tiempo total de ejecución
execution_time=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)
echo -e "\033[1;36mEl script se completó en $execution_time segundos.\033[0m"
echo -e "\033[1;36mEsto equivale a aproximadamente $execution_time_hours horas.\033[0m"

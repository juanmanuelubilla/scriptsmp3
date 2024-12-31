#!/bin/bash

#RUTA ACTUAL
ruta_actual=$(pwd)

#IMPRIMO LA RUTA DONDE SE TRABAJA
echo "LA RUTA ESPECIFICADA ES: $1"
echo "LA CALIDAD ESPECIFICADA PARA LOS M4A es $2"

#INSTALO LO QUE NECESITO
sudo apt-get install ffmpeg faac vorbis-tools atomicparsley mediainfo fdkaac -y

#EXTRAIGO LOS COVER DE LOS ARCHIVOS OGG
sudo ./to_m4a/oggextractimage.sh "$1"

#CONVIERTO LOS ARCHIVOS A M4A
sudo ./to_m4a/oggconvert.sh "$1" 96

#IMPORTO LOS COVER A LOS M4A
sudo ./to_m4a/oggimportimage.sh "$1"

#IMPORTO LA METADATA
sudo ./to_m4a/oggimportmetadata.sh "$1"

#BORRO TODOS LOS JPG
sudo ./to_m4a/oggdeletecover.sh "$1"


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
ogg_files=$(find "$root_directory" -type f -name "*.ogg")

# Si no se encontraron archivos .ogg
if [ -z "$ogg_files" ]; then
  echo "NO SE ENCONTRARON ARCHIVOS .OGG EN '$root_directory'"
  exit 0
fi

# Mostrar los archivos encontrados antes de eliminar
echo "Se encontraron los siguientes archivos .OGG:"
echo "$ogg_files"

# Mostrar el mensaje de confirmación
echo "¡¡¡ATENCIÓN!!! ESTÁS A PUNTO DE ELIMINAR LOS ARCHIVOS .OGG EN '$root_directory'"
echo "¿DESEAS CONTINUAR? (y/n): "
read respuesta

# Si la respuesta es sí, eliminar los archivos .ogg
if [[ "$respuesta" =~ ^[Yy]$ ]]; then
  echo "ELIMINANDO LOS ARCHIVOS .OGG..."
  # Recorrer los archivos encontrados
  while IFS= read -r -d '' archivo; do
    rm "$archivo" && echo "ELIMINADO: $archivo"
  done < <(find "$root_directory" -type f -name "*.ogg" -print0)
  
  echo "ELIMINACIÓN COMPLETA."
else
  echo "NO SE ELIMINÓ NINGÚN ARCHIVO."
fi


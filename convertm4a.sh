#!/bin/bash

#RUTA ACTUAL
ruta_actual=$(pwd)

#IMPRIMO LA RUTA DONDE SE TRABAJA
echo "LA RUTA ESPECIFICADA ES: $1"
echo "LA CALIDAD ESPECIFICADA PARA LOS M4A es $2"

#INSTALO LO QUE NECESITO
sudo apt-get install ffmpeg vorbis-tools atomicparsley mediainfo fdkaac -y

#EXTRAIGO LOS COVER DE LOS ARCHIVOS OGG
sudo ./oggextractimage.sh "$1"

#EXPORTO LA METADATA
#sudo ./oggexportmetadata.sh "$1"

#CONVIERTO LOS ARCHIVOS A M4A
sudo ./oggconvert.sh "$1" 96

#IMPORTO LOS COVER A LOS M4A
sudo ./oggimportimage.sh "$1"

#IMPORTO LA METADATA
sudo ./oggimportmetadata.sh "$1"

#BORRO TODOS LOS JPG
sudo ./oggdeletecover.sh "$1"

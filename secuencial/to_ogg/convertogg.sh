#!/bin/bash

#RUTA ACTUAL
ruta_actual=$(pwd)

#IMPRIMO LA RUTA DONDE SE TRABAJA
echo "LA RUTA ESPECIFICADA ES: $1"

#INSTALO LO QUE NECESITO
sudo apt-get install ffmpeg dir2ogg kid3-cli -y

#VERIFICO E INSTALO POWERSHELL
sudo ./to_ogg/install_powershell.sh

#EJECUTO ARCHIVO BASH PARA RENOMBRAR ARCHIVOS QUE TIENEN CARACTERES RAROS
sudo ./to_ogg/mp3renombrar.sh "$1"

#EXTRAIGO EL COVER DEL ALBUM A UN ARCHIVO
sudo ./to_ogg/mp3extractimage.sh "$1"

#CONVIERTO CARPETAS A OGG
sudo dir2ogg -d "$1" -r -q 4.50 --delete-input

#CAMBIO PERMISOS DE ARCHIVOS
sudo chmod 777 -R "$1"

#EJECUTO SCRIPT DE IMPORTACION DE TAPAS DE ALBUM DE MP3 Y CREACION DE ARCHIVO BASH
sudo pwsh ./to_ogg/mp3script2.ps1 "$1"

#VOY A LA CARPETA DESTINO DEL BASH
cd "$1"

#CAMBIO PERMISOS DEL ARCHIVO BASH
sudo chmod +x IMPORTALBUMCOVER.sh

#EJECUTO ARCHIVO BASH GENERADO DEL PUNTO 10
./IMPORTALBUMCOVER.sh

#ELIMINO EL ARCHIVO IMPORTALBUMCOVER.sh
sudo rm IMPORTALBUMCOVER.sh

#VOY A LA CARPETA DE SCRIPTS
cd $ruta_actual

#EJECUTO SCRIPT DE RENOMBRADO DE NUMERO DE ARCHIVOS
sudo ./to_ogg/renombrar1digito.sh  "$1"

#VUELVO A DONDE ESTABA
cd $ruta_actual
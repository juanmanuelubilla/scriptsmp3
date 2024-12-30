#!/bin/bash

#RUTA ACTUAL
ruta_actual=$(pwd)

#IMPRIMO LA RUTA DONDE SE TRABAJA
echo "LA RUTA ESPECIFICADA ES: $1"

#INSTALO LO QUE NECESITO
sudo apt-get install ffmpeg dir2ogg kid3-cli -y

#CAMBIO PERMISOS DE LA CARPETA PARA GENERAR ARCHIVOS
#sudo chmod 777 -R /mnt/R1/HDD500GB/SPOTIFY/TEMP

#sudo chmod 777 -R $1

# VOY A LA CARPETA DE SCRIPTS
#cd /home/pi/scriptsmp3

#EJECUTO ARCHIVO BASH PARA RENOMBRAR ARCHIVOS QUE TIENEN CARACTERES RAROS
sudo ./mp3renombrar.sh "$1"

#EJECUTO SCRIPT DE EXTRACION DE TAPAS DE ALBUM DE MP3 Y CREACION DE ARCHIVO BASH
#pwsh ./mp3script1.ps1

#VOY A LA CARPETA DESTINO DEL BASH
#cd /mnt/R1/HDD500GB/SPOTIFY/TEMP

#CAMBIO PERMISOS DEL ARCHIVO BASH
#sudo chmod +x EXTRACTALBUMCOVER.sh

#EJECUTO ARCHIVO BASH GENERADO DEL PUNTO 3
#./EXTRACTALBUMCOVER.sh

#EXTRAIGO EL COVER DEL ALBUM A UN ARCHIVO
./mp3extractimage.sh "$1"

#CONVIERTO CARPETAS A OGG
sudo dir2ogg -d "$1" -r -q 4.50 --delete-input

#CAMBIO PERMISOS DE ARCHIVOS
sudo chmod 777 -R "$1"

# VOY A LA CARPETA DE SCRIPTS
#cd /home/pi/scriptsmp3

#EJECUTO SCRIPT DE IMPORTACION DE TAPAS DE ALBUM DE MP3 Y CREACION DE ARCHIVO BASH
sudo pwsh ./mp3script2.ps1 "$1"

#VOY A LA CARPETA DESTINO DEL BASH
cd "$1"

#CAMBIO PERMISOS DEL ARCHIVO BASH
sudo chmod +x IMPORTALBUMCOVER.sh

#EJECUTO ARCHIVO BASH GENERADO DEL PUNTO 10
./IMPORTALBUMCOVER.sh

#ELIMINO EL ARCHIVO IMPORTALBUMCOVER.sh
sudo rm IMPORTALBUMCOVER.sh

#IMPORTO LA IMAGEN DEL ALBUM
#sudo ./mp3importimage.sh /mnt/R1/HDD500GB/SPOTIFY/TEMP

#BORRO LA IMAGEN DEL ALBUM
#sudo ./mp3deleteimage.sh /mnt/R1/HDD500GB/SPOTIFY/TEMP

# VOY A LA CARPETA DE SCRIPTS
cd $ruta_actual

#EJECUTO SCRIPT DE RENOMBRADO DE NUMERO DE ARCHIVOS
#sudo pwsh ./mp3script3.ps1 "$1"
sudo ./renombrar1digito.sh  "$1"

#VOY A LA CARPETA DONDE DEJE EL ARCHIVO IMPORTALBUMCOVER.sh
#cd "$1"

#VUELVO A DONDE ESTABA
cd $ruta_actual
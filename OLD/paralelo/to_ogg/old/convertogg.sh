#!/bin/bash

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

#INSTALO LO QUE NECESITO
sudo apt-get install faac ffmpeg dir2ogg gawk kid3-cli sysstat sysstat findutils flac lame mplayer libimage-exiftool-perl parallel -y

#VERIFICO E INSTALO POWERSHELL
sudo ./to_ogg/install_powershell.sh

#EJECUTO ARCHIVO BASH PARA RENOMBRAR ARCHIVOS QUE TIENEN CARACTERES RAROS
sudo ./to_ogg/mp3renombrar.sh "$1"

#EXTRAIGO EL COVER DEL ALBUM A UN ARCHIVO
sudo ./to_ogg/mp3extractimage.sh "$1"

#CONVIERTO CARPETAS A OGG
sudo ./to_ogg/dir2ogg_convert.sh "$1"

#CAMBIO PERMISOS DE ARCHIVOS
sudo chmod 777 -R "$1"

#EJECUTO SCRIPT DE IMPORTACION DE TAPAS DE ALBUM DE MP3 Y CREACION DE ARCHIVO BASH
sudo pwsh ./to_ogg/mp3script2.ps1 "$1"
#sudo ./to_ogg/createfileimportjpg.sh "$1"

#VOY A LA CARPETA DESTINO DEL BASH
cd "$1"

#CAMBIO PERMISOS DEL ARCHIVO BASH
#sudo chmod +x IMPORTALBUMCOVER.sh


#!/bin/bash

# Define el directorio raíz donde buscar (puedes modificarlo según tus necesidades)
DIRECTORIO="$1"

# Busca los archivos con el patrón IMPORTALBUMCOVER*.sh y aplica chmod +x
echo "Buscando archivos IMPORTALBUMCOVER*.sh en $DIRECTORIO..."
ARCHIVOS_ENCONTRADOS=$(find "$DIRECTORIO" -type f -name "IMPORTALBUMCOVER*.sh")

if [ -z "$ARCHIVOS_ENCONTRADOS" ]; then
    echo "No se encontraron archivos que coincidan con el patrón."
else
    echo "Archivos encontrados:"
    echo "$ARCHIVOS_ENCONTRADOS"
    echo ""
    echo "Otorgando permisos de ejecución..."
    
    while IFS= read -r ARCHIVO; do
        chmod +x "$ARCHIVO"
        if [ $? -eq 0 ]; then
            echo "Permisos otorgados correctamente a: $ARCHIVO"
        else
            echo "Error al otorgar permisos a: $ARCHIVO"
        fi
    done <<< "$ARCHIVOS_ENCONTRADOS"
    
    echo ""
    echo "Operación completada."
fi




#EJECUTO ARCHIVO BASH GENERADO DEL PUNTO 10
#./IMPORTALBUMCOVER.sh


sudo ./IMPORTALBUMCOVER_1.sh
sudo ./IMPORTALBUMCOVER_2.sh
sudo ./IMPORTALBUMCOVER_3.sh
sudo ./IMPORTALBUMCOVER_4.sh
sudo ./IMPORTALBUMCOVER_5.sh
sudo ./IMPORTALBUMCOVER_6.sh
sudo ./IMPORTALBUMCOVER_7.sh
sudo ./IMPORTALBUMCOVER_8.sh

# Esperar a que todos los procesos terminen
wait











#ELIMINO EL ARCHIVO IMPORTALBUMCOVER.sh
#sudo rm IMPORTALBUMCOVER.sh

#VOY A LA CARPETA DE SCRIPTS
cd $ruta_actual

#EJECUTO SCRIPT DE RENOMBRADO DE NUMERO DE ARCHIVOS
sudo ./to_ogg/renombrar1digito.sh  "$1"

#VUELVO A DONDE ESTABA
cd $ruta_actual

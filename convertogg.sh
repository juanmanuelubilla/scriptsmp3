#!/bin/bash

clear

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi



# Registrar el tiempo inicial
start_time2=$(date +%s)

# Verificar que se haya proporcionado un argumento
if [ -z "$1" ]; then
  echo -e "\033[1;33mPor favor, ingresa un directorio valido.\033[0m"
  exit 1
fi

# Verificar si el argumento es un directorio válido
if [ ! -d "$1" ]; then
  echo -e "\033[1;33mEl parametro ingresado no es un directorio existente.\033[0m"
  exit 1
fi

# Contar carpetas y archivos en el directorio proporcionado
carpetas=$(find "$1" -type d | wc -l)
archivos=$(find "$1" -type f | wc -l)

info="\nLA RUTA ESPECIFICADA ES: $1\nCARPETAS: $((carpetas - 1))\nARCHIVOS: $archivos"

# Instalaciones automáticas
apt-get install faac ffmpeg dir2ogg gawk kid3-cli sysstat sysstat findutils flac lame mplayer libimage-exiftool-perl parallel bc -y > /dev/null 2>&1
#whiptail --title "Instalando dependencias" --infobox "Instalando paquetes necesarios..." 8 50
apt-get install faac ffmpeg dir2ogg gawk kid3-cli sysstat findutils flac lame mplayer libimage-exiftool-perl parallel bc -y > /dev/null 2>&1

./to_ogg/install_powershell.sh > /dev/null 2>&1


#EJECUTANDO SCRIPT
echo ""
echo -e "\033[1;33mEJECUTANDO SCRIPT DE CONVERSION DE ARCHIVOS DE MP3 a OGG\033[0m"
echo -e "\033[1;33m========================================================\033[0m"
echo ""

# Mostrar la hora de inicio en formato HH:MM:SS DD/MM/YYYY
echo "Inicio del proceso: $(date '+%H:%M:%S %d/%m/%Y')"
echo ""
echo "LA RUTA ESPECIFICADA ES: $1"
echo "CARPETAS: $((carpetas - 1))"
echo "ARCHIVOS: $archivos"

# Menú interactivo con whiptail
opciones=$(whiptail --title "CONVERTIR MP3 A OGG" --checklist "$(echo -e "$info\n\nUsa la barra espaciadora para seleccionar/desmarcar y ENTER para confirmar:")" 20 100 6 \
"1" "Renombrar archivos con caracteres raros" ON \
"2" "Extraer cover del álbum" ON \
"3" "Convertir carpetas a OGG" ON \
"4" "Ejecutar importación de tapas de álbum" ON \
"5" "Renombrar archivos con un solo dígito" ON \
"6" "Buscar Tags de Nombre / Album / Artista en archivos sin tags" OFF 3>&1 1>&2 2>&3)


# Verificar si el usuario canceló la operación
if [ $? -ne 0 ]; then
  echo "Operación cancelada."
  exit 1
fi

# Convertir las opciones seleccionadas en un array y eliminar comillas
IFS=' ' read -r -a opciones <<< "$(echo $opciones | tr -d '"')"

# Ejecutar las opciones seleccionadas
for opcion in "${opciones[@]}"; do
  case $opcion in
    1)
      ./to_ogg/mp3renombrar.sh "$1"
      ;;
    2)
      ./to_ogg/mp3extractimage.sh "$1"
      ;;
    3)
      ./to_ogg/dir2ogg_convert.sh "$1"
      ;;
    4)
      # Registrar el tiempo inicial
      start_time=$(date +%s)
      
      echo ""
      echo -e "\033[1;36m+----------------------------------------------+\033[0m"
      echo -e "\033[1;36m|       IMPORTACION DE COVERS A OGG...         |\033[0m"
      echo -e "\033[1;36m+----------------------------------------------+\033[0m"
      echo ""
      
      chmod 777 -R -v "$1" > /dev/null 2>&1

      echo "Creando archivos de importación de tapas de álbum..."
      echo ""
      
      pwsh ./to_ogg/mp3script2-multiplesarchivos.ps1 "$1"
      echo ""
      
      echo "Ejecutando archivos de importación de tapas de álbum..."
      echo ""
      
      find "$1" -type f -name "IMPORTALBUMCOVER*.sh" | xargs -I {} -P $(nproc) bash -c 'chmod +x "{}" && "{}"'
      
      cd $1
      rm IMPORTALBUMCOVER*.sh
      cd - > /dev/null 2>&1


      echo ""
      echo "Eliminando archivos temporales..."
	  echo ""
      ./to_ogg/delete_tmp.sh "$1"

      # Tiempo total de ejecución
      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$((duration / 60))
      seconds=$((duration % 60))

      echo ""
      echo "Duracion del proceso de importacion de covers: ${minutes}m ${seconds}s"
      echo ""
      echo -e "\033[1;36m+----------------------------------------------+\033[0m"
      #echo ""
      ;;
    5)
      ./to_ogg/renombrar1digito.sh "$1"
      ;;
    6)
      # Registrar el tiempo inicial
      start_time=$(date +%s)
      
      echo ""
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo -e "\033[1;36m|        Buscando TAGS en archivos huerfanos            |\033[0m"
      echo -e "\033[1;36m| Los archivos modificados se copiaran a \home\pi\Music |\033[0m"
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo ""
      
      beet import "$1"

      # Tiempo total de ejecución
      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$((duration / 60))
      seconds=$((duration % 60))

      ;;
    *)
      echo "Opción no válida: $opcion"
      ;;
      
  esac
done

# Registrar el tiempo final
end_time=$(date +%s)
execution_time=$((end_time - start_time2))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)
echo ""
echo "El script total se completó en $execution_time segundos"
echo "Esto equivale a aproximadamente $execution_time_hours horas"
echo ""

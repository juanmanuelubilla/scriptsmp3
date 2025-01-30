#!/bin/bash

# Registrar el tiempo inicial
start_time=$(date +%s)

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
sudo apt-get install faac ffmpeg dir2ogg gawk kid3-cli sysstat sysstat findutils flac lame mplayer libimage-exiftool-perl parallel bc -y
sudo ./to_ogg/install_powershell.sh

# Menú interactivo con whiptail
opciones=$(whiptail --title "CONVERTIR MP3 A OGG" --checklist "$(echo -e "$info\n\nUsa la barra espaciadora para seleccionar/desmarcar y ENTER para confirmar:")" 20 78 8 \
"1" "Renombrar archivos con caracteres raros" ON \
"2" "Extraer cover del álbum" ON \
"3" "Convertir carpetas a OGG" ON \
"4" "Ejecutar importación de tapas de álbum" ON \
"5" "Renombrar archivos con un solo dígito" ON 3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
  echo "Operación cancelada."
  exit 1
fi

# Convertir opciones seleccionadas en un array
IFS=' ' read -r -a opciones <<< "$opciones"

# Ejecutar las opciones seleccionadas
for opcion in "${opciones[@]}"; do
  case $opcion in
    1)
      echo "Renombrando archivos con caracteres raros..."
      sudo ./to_ogg/mp3renombrar.sh "$1"
      ;;
    2)
      echo "Extrayendo cover del álbum..."
      sudo ../secuencial/to_ogg/mp3extractimage.sh "$1"
      ;;
    3)
      echo "Convirtiendo carpetas a OGG..."
      sudo ./to_ogg/dir2ogg_convert.sh "$1"
      ;;
    4)
      echo "Cambiando permisos..."
      sudo chmod 777 -R -v "$1"

      echo "Ejecutando importación de tapas de álbum..."
      sudo pwsh ./to_ogg/mp3script2-multiplesarchivos.ps1 "$1"
      find "$1" -type f -name "IMPORTALBUMCOVER*.sh" | xargs -I {} -P $(nproc) bash -c 'chmod +x "{}" && "{}"'
      sudo rm IMPORTALBUMCOVER*.sh

      echo "Eliminando archivos temporales..."
      sudo ./to_ogg/delete_tmp.sh "$1"}
      ;;
    5)
      echo "Renombrando archivos con un solo dígito..."
      sudo ./to_ogg/renombrar1digito.sh "$1"
      ;;
    *)
      echo "Opción no válida: $opcion"
      ;;
  esac
done

# Registrar el tiempo final
end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)
echo -e "\033[1;36mEl script se completó en $execution_time segundos.\033[0m"
echo -e "\033[1;36mEsto equivale a aproximadamente $execution_time_hours horas.\033[0m"

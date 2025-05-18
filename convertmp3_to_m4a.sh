#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi

# Verificar que se haya proporcionado un argumento
if [ -z "$1" ]; then
  echo -e "\033[1;33mPor favor, ingresa un directorio válido.\033[0m"
  exit 1
fi

# Verificar si el argumento es un directorio válido
if [ ! -d "$1" ]; then
  echo -e "\033[1;33mEl parámetro ingresado no es un directorio existente.\033[0m"
  exit 1
fi

DIR="$1"

# *** Eliminar la petición de calidad M4A ***

# Instalar paquetes sin preguntar
echo "Instalando paquetes necesarios..."
apt-get install ffmpeg faac vorbis-tools atomicparsley mediainfo fdkaac parallel -y

script_start_time=$(date +%s)

# Contar carpetas y archivos
carpetas=$(find "$DIR" -type d | wc -l)
archivos=$(find "$DIR" -type f | wc -l)

echo ""
echo -e "\033[1;33m========================================================\033[0m"
echo -e "\033[1;33mEJECUTANDO SCRIPT DE CONVERSION DE ARCHIVOS DE MP3 a M4A\033[0m"
echo -e "\033[1;33m========================================================\033[0m"
echo ""

info="\nLA RUTA ESPECIFICADA ES: $DIR\nCARPETAS: $((carpetas - 1))\nARCHIVOS: $archivos"

# Mostrar la hora de inicio
echo "Inicio del proceso: $(date '+%H:%M:%S %d/%m/%Y')"
echo ""
echo "LA RUTA ESPECIFICADA ES: $DIR"
echo "CARPETAS: $((carpetas - 1))"
echo "ARCHIVOS: $archivos"

# Mostrar menú para selección múltiple
opcion=$(whiptail --title "CONVERTIR ARCHIVOS DE MP3 A M4A" --checklist "$(echo -e "$info\n\nUsa la barra espaciadora para seleccionar/desmarcar y ENTER para confirmar:")" 20 100 8 \
  "1" "Renombrar archivos con caracteres raros" ON \
  "2" "Extraer covers de archivos OGG" ON \
  "3" "Convertir archivos a M4A" ON \
  "4" "Importar covers a M4A" ON \
  "5" "Borrar archivos JPG" ON \
  "6" "Eliminar archivos .mp3" ON \
  "7" "Buscar Tags de Nombre / Album / Artista en archivos sin tags" OFF 3>&1 1>&2 2>&3)

# Verificar cancelación
if [ $? -ne 0 ]; then
  echo "Operación cancelada."
  exit 1
fi

# Convertir las opciones seleccionadas en array y eliminar comillas
IFS=' ' read -r -a opciones <<< "$(echo $opcion | tr -d '"')"

# Ejecutar opciones seleccionadas
for opt in "${opciones[@]}"; do
  case $opt in
    1)
      ./to_ogg/mp3renombrar.sh "$DIR"
      ;;
    2)
      ./mp3_to_m4a/mp3extractimage.sh "$DIR"
      ;;
    3)
      ./mp3_to_m4a/mp3convert.sh "$DIR"
      ;;
    4)
      ./mp3_to_m4a/mp3importimage.sh "$DIR"
      ;;
    5)
      ./mp3_to_m4a/mp3deletecover.sh "$DIR"
      ;;
    6)
      start_time=$(date +%s)

      echo ""
      echo -e "\033[1;36m+----------------------------------------------+\033[0m"
      echo -e "\033[1;36m|            BORRAR ARCHIVOS MP3...            |\033[0m"
      echo -e "\033[1;36m+----------------------------------------------+\033[0m"
      echo ""

      mp3_files=$(find "$DIR" -type f -name "*.mp3")

      if [ -z "$mp3_files" ]; then
        echo "No se encontraron archivos .mp3 en $DIR"
      else
        echo "¡ATENCIÓN!"
        echo "Se eliminarán los archivos .mp3 en: $DIR"
        read -p "¿Deseas continuar? (Y/n): " respuesta
        if [[ "$respuesta" =~ ^[Yy]$ ]]; then
          while IFS= read -r archivo; do
            rm "$archivo" && echo "Eliminado: $archivo"
          done <<< "$mp3_files"
          echo "Eliminación completada."
        else
          echo "No se eliminó ningún archivo."
        fi
      fi

      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$((duration / 60))
      seconds=$((duration % 60))
      echo "Archivos eliminados en: ${minutes}m ${seconds}s"
      ;;
    7)
      start_time=$(date +%s)

      echo ""
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo -e "\033[1;36m|        Buscando TAGS en archivos huerfanos            |\033[0m"
      echo -e "\033[1;36m| Los archivos modificados se copiarán a /home/pi/Music |\033[0m"
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo ""

      beet import "$DIR"

      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$((duration / 60))
      seconds=$((duration % 60))
      echo "Duración de la búsqueda: ${minutes}m ${seconds}s"
      ;;
    *)
      echo "Opción no válida: $opt"
      ;;
  esac
done

script_end_time=$(date +%s)
execution_time=$((script_end_time - script_start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)

echo ""
echo "------------------------------------------------------------"
echo "El script se completó en $execution_time segundos."
echo "Esto equivale a aproximadamente $execution_time_hours horas."

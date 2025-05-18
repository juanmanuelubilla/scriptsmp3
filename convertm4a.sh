#!/bin/bash

clear

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi

# Registrar el tiempo inicial
start_time=$(date +%s)

# Verificar que se haya proporcionado un argumento
if [ -z "$1" ]; then
  echo "Por favor, proporciona un directorio."
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "El argumento proporcionado no es un directorio válido."
  exit 1
fi

DIRECTORIO="$1"
CALIDAD="${2:-96}"  # Si no se pasa calidad, usar 96 por defecto

# Función para instalar dependencias
instalar_dependencias() {
  echo "Instalando dependencias necesarias..."
  apt-get install -y ffmpeg faac vorbis-tools atomicparsley mediainfo fdkaac parallel whiptail
}

# Instalar dependencias obligatoriamente al inicio
instalar_dependencias

# Contar carpetas y archivos en el directorio proporcionado
carpetas=$(find "$DIRECTORIO" -type d | wc -l)
archivos=$(find "$DIRECTORIO" -type f | wc -l)

# Mostrar información inicial
echo ""
echo -e "\033[1;33m========================================================\033[0m"
echo -e "\033[1;33mEJECUTANDO SCRIPT DE CONVERSIÓN DE ARCHIVOS DE OGG a M4A\033[0m"
echo -e "\033[1;33m========================================================\033[0m"
echo ""

echo "Inicio del proceso: $(date '+%H:%M:%S %d/%m/%Y')"
echo "LA RUTA ESPECIFICADA ES: $DIRECTORIO"
echo "CARPETAS: $((carpetas - 1))"
echo "ARCHIVOS: $archivos"
echo ""

# Crear mensaje para el checklist
mensaje="Ruta: $DIRECTORIO\nCarpetas: $((carpetas - 1))\nArchivos: $archivos\n\nSelecciona las opciones que quieres ejecutar:\n(Usa espacio para marcar, ENTER para confirmar)"

# Menú interactivo
opciones=$(whiptail --title "CONVERSIÓN DE OGG A M4A" --checklist "$mensaje" 20 80 9 \
"1" "Renombrar archivos con caracteres raros" ON \
"2" "Extraer cover de archivos OGG" ON \
"3" "Convertir archivos a M4A (calidad: $CALIDAD)" ON \
"4" "Importar covers a M4A" ON \
"5" "Importar metadata a M4A" ON \
"6" "Borrar archivos JPG (covers)" ON \
"7" "Eliminar archivos .OGG (confirmación)" ON \
"8" "Buscar Tags de Nombre / Álbum / Artista en archivos sin tags" OFF 3>&1 1>&2 2>&3)

# Verificar si el usuario canceló
if [ $? -ne 0 ]; then
  echo "Operación cancelada."
  exit 1
fi

# Convertir string de opciones a array, eliminando comillas y separando correctamente
readarray -t opciones_array < <(echo "$opciones" | tr -d '"' | tr ' ' '\n')

eliminar_ogg() {
  echo "Buscando archivos .ogg en $DIRECTORIO..."
  ogg_files=$(find "$DIRECTORIO" -type f -name "*.ogg")
  if [ -z "$ogg_files" ]; then
    echo "No se encontraron archivos .ogg para eliminar."
    return
  fi

  echo "Archivos .ogg encontrados:"
  echo "$ogg_files"

  echo -e "\e[31m¡¡¡ATENCIÓN!!! Estás a punto de eliminar todos los archivos .ogg en '$DIRECTORIO'.\e[0m"
  read -p "¿Deseas continuar? (y/n): " respuesta
  if [[ "$respuesta" =~ ^[Yy]$ ]]; then
    echo "Eliminando archivos .ogg..."
    find "$DIRECTORIO" -type f -name "*.ogg" -print0 | while IFS= read -r -d '' archivo; do
      rm "$archivo" && echo "Eliminado: $archivo"
    done
    echo "Eliminación completa."
  else
    echo "No se eliminaron archivos .ogg."
  fi
}

# Procesar opciones seleccionadas
for opcion in "${opciones_array[@]}"; do
  case $opcion in
    1)
      ./to_ogg/mp3renombrar.sh "$DIRECTORIO"
      ;;
    2)
      ./to_m4a/oggextractimage.sh "$DIRECTORIO"
      ;;
    3)
      ./to_m4a/oggconvert.sh "$DIRECTORIO" "$CALIDAD"
      ;;
    4)
      ./to_m4a/oggimportimage.sh "$DIRECTORIO"
      ;;
    5)
      ./to_m4a/oggimportmetadata.sh "$DIRECTORIO"
      ;;
    6)
      ./to_m4a/oggdeletecover.sh "$DIRECTORIO"
      ;;
    7)
      eliminar_ogg
      ;;
    8)
      echo ""
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo -e "\033[1;36m|        Buscando TAGS en archivos huérfanos            |\033[0m"
      echo -e "\033[1;36m| Los archivos modificados se copiarán a /home/pi/Music |\033[0m"
      echo -e "\033[1;36m+-------------------------------------------------------+\033[0m"
      echo ""

      beet import "$DIRECTORIO"
      ;;
    *)
      echo "Opción inválida: $opcion"
      ;;
  esac
done

# Calcular tiempo total
end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time / 3600" | bc)

echo ""
echo -e "\033[1;36mEl script se completó en $execution_time segundos.\033[0m"
echo -e "\033[1;36mEsto equivale a aproximadamente $execution_time_hours horas.\033[0m"

#!/bin/bash

clear

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root"
  exit 1
fi

# Función para pedir la ruta de origen
function pedir_ruta_origen() {
  while true; do
    ORIGEN=$(whiptail --inputbox "Introduce la ruta de origen:" 10 60 --title "Ruta de Origen" 3>&1 1>&2 2>&3) || exit 1
    if [ ! -d "$ORIGEN" ]; then
      whiptail --title "Error" --msgbox "La ruta de origen no existe o no es un directorio.\nIntenta de nuevo." 10 60
    else
      break
    fi
  done
}

# Función para pedir ruta destino
function pedir_ruta_destino() {
  DESTINO=$(whiptail --inputbox "Introduce la ruta de destino (opcional):" 10 60 --title "Ruta de Destino" 3>&1 1>&2 2>&3) || exit 1
  if [ -z "$DESTINO" ]; then
    PATH_FINAL="$ORIGEN"
  else
    PATH_FINAL="$DESTINO"
  fi
}

# Función para copiar si corresponde (solo si ORIGEN != DESTINO)
function copiar_si_corresponde() {
  if [ -n "$DESTINO" ] && [ "$DESTINO" != "$ORIGEN" ]; then
    mkdir -p "$DESTINO"

    whiptail --title "Copiando archivos" --infobox "Copiando de:\n$ORIGEN\n→ $DESTINO..." 10 60
    sleep 1

    rsync -a --info=progress2 "$ORIGEN"/ "$DESTINO"/ 2>&1 | stdbuf -oL \
    awk '
      {
        for(i=1;i<=NF;i++) {
          if ($i ~ /[0-9]+%/) {
            gsub(/%/,"",$i)
            print $i
            fflush()
          }
        }
      }
    ' | whiptail --title "Progreso de Copia" --gauge "Copiando archivos..." 10 70 0

    if [ $? -ne 0 ]; then
      whiptail --title "Error" --msgbox "Fallo al copiar archivos a $DESTINO." 10 60
      exit 1
    fi

    whiptail --title "Copia completada" --msgbox "Copia realizada:\n$ORIGEN\n→ $DESTINO" 12 60
  fi
}

# Pedir rutas inicialmente
pedir_ruta_origen
pedir_ruta_destino

# Mostrar menú principal
while true; do
  MENU_MSG="ORIGEN: $ORIGEN\nDESTINO: ${DESTINO:-(no definido)}\n\nPATH FINAL: $PATH_FINAL\n\nSeleccione una opción:"
  OPCION=$(whiptail --title "CONVERSIÓN DE AUDIO" --menu "$MENU_MSG" 20 70 10 \
    "1" "Convertir MP3 a OGG" \
    "2" "Convertir OGG a M4A para el auto" \
    "3" "Script C - Análisis de carpetas" \
    " " " " \
    "4" "Editar ruta de ORIGEN" \
    "5" "Editar ruta de DESTINO" \
    " " " " \
    "6" "Salir" 3>&1 1>&2 2>&3) || exit 1

  case $OPCION in
    1|2|3)
      copiar_si_corresponde
      case $OPCION in
        1) ./convertogg.sh "$PATH_FINAL"; exit 0 ;;
        2) ./scripts/script_b.sh "$PATH_FINAL"; exit 0 ;;
        3) ./scripts/script_c.sh "$PATH_FINAL"; exit 0 ;;
      esac
      ;;
    4)
      pedir_ruta_origen
      PATH_FINAL="${DESTINO:-$ORIGEN}"
      ;;
    5)
      pedir_ruta_destino
      PATH_FINAL="${DESTINO:-$ORIGEN}"
      ;;
    6)
      exit 0
      ;;
    *)
      whiptail --msgbox "Opción inválida." 8 40
      ;;
  esac
done

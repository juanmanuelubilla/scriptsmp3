#!/bin/bash
# Punto de entrada principal: menú whiptail + opción de interfaz gráfica.

clear

if [[ "$EUID" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root: sudo ./inicio.sh"
  exit 1
fi

_REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/install_deps.sh
source "$_REPO_ROOT/lib/install_deps.sh"
# shellcheck source=lib/ui_common.sh
source "$_REPO_ROOT/lib/ui_common.sh"

install_deps_inicio >/dev/null 2>&1
require_whiptail || exit 1

if whiptail --title "Dependencias" --yesno \
  "¿Instalar o actualizar TODAS las dependencias del sistema?\n\n(incluye ffmpeg, dir2ogg, AtomicParsley, lame, etc.)\n\nRecomendado la primera vez o tras actualizar Debian." \
  14 72; then
  whiptail --title "Instalando" --infobox "Instalando paquetes…\nPuede tardar unos minutos." 8 50
  install_deps_all 2>&1 | tee /tmp/scriptsmp3_apt.log
  whiptail --title "Listo" --msgbox "Instalación de paquetes finalizada.\nRevisa la terminal si hubo avisos." 10 60
fi

function pedir_ruta_origen() {
  while true; do
    ORIGEN=$(whiptail --inputbox "Introduce la ruta de origen:" 10 70 "$ORIGEN" --title "Ruta de origen" 3>&1 1>&2 2>&3) || exit 1
    if [ ! -d "$ORIGEN" ]; then
      whiptail --title "Error" --msgbox "La ruta de origen no existe o no es un directorio.\nIntenta de nuevo." 10 60
    else
      break
    fi
  done
}

function pedir_ruta_destino() {
  DESTINO=$(whiptail --inputbox "Introduce la ruta de destino (opcional).\nDeja vacío para trabajar solo en origen:" 12 70 "$DESTINO" --title "Ruta de destino" 3>&1 1>&2 2>&3) || exit 1
  if [ -z "$DESTINO" ]; then
    PATH_FINAL="$ORIGEN"
  else
    if [ ! -d "$DESTINO" ]; then
      whiptail --title "Confirmar" --yesno "El destino no existe.\n¿Crear carpeta?\n$DESTINO" 12 70 || return 1
      mkdir -p "$DESTINO" || {
        whiptail --msgbox "No se pudo crear el directorio." 8 50
        return 1
      }
    fi
    PATH_FINAL="$DESTINO"
  fi
}

function actualizar_path_final() {
  if [ -n "$DESTINO" ]; then
    PATH_FINAL="$DESTINO"
  else
    PATH_FINAL="$ORIGEN"
  fi
}

function copiar_si_corresponde() {
  if [ -n "$DESTINO" ] && [ "$DESTINO" != "$ORIGEN" ]; then
    whiptail_rsync_copy "$ORIGEN" "$DESTINO" || exit 1
  fi
}

function lanzar_interfaz_grafica() {
  if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    whiptail --title "Interfaz gráfica" --msgbox \
      "No hay sesión gráfica (DISPLAY).\n\nEjecuta desde el escritorio o usa:\n  python3 $_REPO_ROOT/audio_converter.py" \
      12 70
    return 1
  fi

  whiptail --title "Interfaz gráfica" --infobox "Instalando dependencias Python…" 8 50
  if ! install_deps_gui; then
    whiptail --title "Error" --msgbox "No se pudieron instalar python3-tk, mutagen o ffmpeg." 10 60
    return 1
  fi

  export AUDIO_CONVERTER_DIR="$PATH_FINAL"
  cd "$_REPO_ROOT" || exit 1

  # Si hay usuario real (sudo), abrir GUI como ese usuario para evitar problemas X11
  if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    _xauth="${XAUTHORITY:-$(eval echo "~$SUDO_USER")/.Xauthority}"
    sudo -u "$SUDO_USER" env DISPLAY="${DISPLAY:-}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
      XAUTHORITY="$_xauth" AUDIO_CONVERTER_DIR="$PATH_FINAL" \
      python3 "$_REPO_ROOT/audio_converter.py" &
  else
    python3 "$_REPO_ROOT/audio_converter.py" &
  fi

  whiptail --title "Interfaz gráfica" --msgbox \
    "Se abrió el conversor gráfico.\n\nCarpeta sugerida: $PATH_FINAL\n\nPuedes seguir usando este menú en la terminal." \
    12 70
}

ORIGEN=""
DESTINO=""
PATH_FINAL=""

pedir_ruta_origen
pedir_ruta_destino

while true; do
  MENU_MSG=$(whiptail_msg "ORIGEN:\n  $ORIGEN\n\nDESTINO:\n  ${DESTINO:-(misma carpeta que origen)}\n\nTRABAJO EN:\n  $PATH_FINAL\n\nElige una opción:")
  OPCION=$(whiptail --title "CONVERSIÓN DE AUDIO" --menu "$MENU_MSG" 24 78 10 \
    "1" "Convertir MP3 → OGG (menú bash)" \
    "2" "Convertir OGG → M4A para el auto (menú bash)" \
    "3" "Convertir MP3 → M4A para el auto (menú bash)" \
    "4" "Convertir OGG → MP3 (menú bash)" \
    "5" "Abrir interfaz gráfica (Python)" \
    "6" "Cambiar ruta de ORIGEN" \
    "7" "Cambiar ruta de DESTINO" \
    "8" "Instalar todas las dependencias" \
    "9" "Salir" 3>&1 1>&2 2>&3) || exit 0

  case $OPCION in
    1|2|3|4)
      copiar_si_corresponde
      case $OPCION in
        1) "$_REPO_ROOT/convertogg.sh" "$PATH_FINAL"; exit 0 ;;
        2) "$_REPO_ROOT/convertm4a.sh" "$PATH_FINAL"; exit 0 ;;
        3) "$_REPO_ROOT/convertmp3_to_m4a.sh" "$PATH_FINAL"; exit 0 ;;
        4) "$_REPO_ROOT/convertmp3.sh" "$PATH_FINAL"; exit 0 ;;
      esac
      ;;
    5)
      lanzar_interfaz_grafica
      ;;
    6)
      pedir_ruta_origen
      actualizar_path_final
      ;;
    7)
      pedir_ruta_destino
      actualizar_path_final
      ;;
    8)
      install_deps_all 2>&1 | tee /tmp/scriptsmp3_apt.log
      whiptail --title "Dependencias" --msgbox "Instalación completada." 8 40
      ;;
    9)
      exit 0
      ;;
    *)
      whiptail --msgbox "Opción inválida." 8 40
      ;;
  esac
done

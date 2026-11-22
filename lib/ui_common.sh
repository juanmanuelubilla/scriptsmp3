# Utilidades TUI: whiptail, barras de progreso y copia con gauge.
# Uso: source "$REPO_ROOT/lib/ui_common.sh"

UI_BAR_WIDTH="${UI_BAR_WIDTH:-50}"

# Convierte \n literales en saltos de línea (whiptail/newt).
whiptail_msg() {
  echo -e "$*"
}

# Extrae IDs numéricos del resultado de whiptail --checklist.
whiptail_parse_checklist() {
  local raw="$1"
  if [ -z "$raw" ]; then
    return 0
  fi
  grep -oE '[0-9]+' <<< "$raw" | sort -n -u
}

# Comprueba que whiptail esté disponible antes de mostrar menús.
require_whiptail() {
  if command -v whiptail &>/dev/null; then
    return 0
  fi
  echo "Error: whiptail no está instalado. Ejecuta: apt install whiptail" >&2
  return 1
}

# Dibuja barra en la terminal (evita mezclar con logs en stdout).
ui_bar_render() {
  local current="$1"
  local total="$2"
  local percent=0
  local fill=0
  local bar spaces

  [ "$total" -gt 0 ] || total=1
  [ "$current" -gt "$total" ] && current="$total"

  percent=$((current * 100 / total))
  fill=$((current * UI_BAR_WIDTH / total))
  [ "$fill" -gt "$UI_BAR_WIDTH" ] && fill="$UI_BAR_WIDTH"

  bar=$(printf "%-${fill}s" "#" | tr ' ' '#')
  spaces=$(printf "%-$((UI_BAR_WIDTH - fill))s" " ")
  local line
  line=$(printf '\r[%s%s] %3d%% (%d/%d)' "$bar" "$spaces" "$percent" "$current" "$total")

  if [ -w /dev/tty ] 2>/dev/null; then
    printf '%s' "$line" >/dev/tty
  else
    printf '%s' "$line"
  fi
}

ui_bar_finish() {
  if [ -w /dev/tty ] 2>/dev/null; then
    printf '\n' >/dev/tty
  else
    echo ""
  fi
}

# Progreso en tareas paralelas (contador en archivo + flock).
ui_progress_file_init() {
  local count_file="$1"
  echo 0 >"$count_file"
}

ui_progress_file_tick() {
  local count_file="$1"
  local total="$2"
  local lock_file="$3"
  local current

  {
    flock -x 200
    current=$(($(cat "$count_file") + 1))
    echo "$current" >"$count_file"
    ui_bar_render "$current" "$total"
  } 200>"$lock_file"
}

# Copia ORIGEN → DESTINO con barra whiptail --gauge (0-100).
whiptail_rsync_copy() {
  local origen="$1"
  local destino="$2"

  mkdir -p "$destino"

  (
    set -o pipefail
    rsync -a --info=progress2 "$origen"/ "$destino"/ 2>&1 | {
      local pct=0
      while IFS= read -r line; do
        local np
        np=$(grep -oE '[0-9]+%' <<<"$line" | tail -1 | tr -d '%')
        if [ -n "$np" ] && [ "$np" -ge "$pct" ] 2>/dev/null; then
          pct="$np"
          echo "$pct"
        fi
      done
      echo 100
    } | whiptail --title "Progreso de copia" --gauge "Copiando archivos…" 10 70 0
  )

  local rc=${PIPESTATUS[0]}
  if [ "$rc" -ne 0 ]; then
    whiptail --title "Error" --msgbox "Fallo al copiar archivos a:\n$destino" 10 60
    return "$rc"
  fi
  whiptail --title "Copia completada" --msgbox "Copia realizada:\n$origen\n→ $destino" 12 60
  return 0
}

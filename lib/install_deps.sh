# Dependencias apt compatibles con Debian 12/13 (sin faac ni fdkaac).
# Uso: source "$(dirname "$0")/lib/install_deps.sh" && install_deps_m4a

_SCRIPTSMP3_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ¿Tiene candidato instalable en apt? (Debian 13: faac/fdkaac → Candidate: (none))
_pkg_has_candidate() {
  local cand
  cand=$(apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2; exit}')
  [[ -n "$cand" && "$cand" != "(none)" ]]
}

# Instala solo paquetes con candidato en apt; omite obsoletos o inexistentes.
apt_install_available() {
  local pkg to_install=()
  for pkg in "$@"; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
      continue
    fi
    if _pkg_has_candidate "$pkg"; then
      to_install+=("$pkg")
    else
      echo "Aviso: paquete no disponible en este sistema (omitido): $pkg" >&2
    fi
  done
  if [ ${#to_install[@]} -eq 0 ]; then
    return 0
  fi
  echo "Instalando: ${to_install[*]}"
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${to_install[@]}"
}

require_command() {
  local cmd="$1" pkg="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    return 0
  fi
  echo "Falta '$cmd'. Intentando instalar paquete '$pkg'…" >&2
  apt_install_available "$pkg"
  command -v "$cmd" &>/dev/null
}

# OGG → M4A, MP3 → M4A (ffmpeg + AtomicParsley + mediainfo)
install_deps_m4a() {
  apt_install_available \
    ffmpeg \
    atomicparsley \
    mediainfo \
    parallel \
    whiptail \
    bc \
    vorbis-tools
  require_command ffmpeg ffmpeg
  require_command AtomicParsley atomicparsley
  require_command mediainfo mediainfo
}

# OGG → MP3
install_deps_ogg_to_mp3() {
  apt_install_available \
    ffmpeg \
    lame \
    vorbis-tools \
    mediainfo \
    parallel \
    eyed3 \
    whiptail \
    bc
  require_command ffmpeg ffmpeg
  require_command lame lame
  require_command eyeD3 eyed3
}

# MP3 → OGG
install_deps_mp3_to_ogg() {
  apt_install_available \
    ffmpeg \
    dir2ogg \
    gawk \
    kid3-cli \
    findutils \
    flac \
    lame \
    mplayer \
    libimage-exiftool-perl \
    parallel \
    bc \
    whiptail \
    vorbis-tools
  require_command ffmpeg ffmpeg
  require_command dir2ogg dir2ogg
}

# inicio.sh (copia con rsync)
install_deps_inicio() {
  apt_install_available whiptail rsync bc
}

# Todas las dependencias de los flujos bash (sin duplicar faac/fdkaac)
install_deps_all() {
  apt_install_available \
    ffmpeg \
    atomicparsley \
    mediainfo \
    parallel \
    whiptail \
    bc \
    rsync \
    vorbis-tools \
    lame \
    eyed3 \
    dir2ogg \
    gawk \
    kid3-cli \
    findutils \
    flac \
    mplayer \
    libimage-exiftool-perl
  require_command ffmpeg ffmpeg
  require_command whiptail whiptail
}

# Interfaz gráfica Python (tkinter + mutagen)
install_deps_gui() {
  apt_install_available ffmpeg python3 python3-tk python3-pip
  if ! python3 -c "import mutagen" 2>/dev/null; then
    apt_install_available python3-mutagen || true
  fi
  if ! python3 -c "import mutagen" 2>/dev/null; then
    python3 -m pip install --user mutagen 2>/dev/null || \
      python3 -m pip install --break-system-packages mutagen 2>/dev/null || true
  fi
  if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "Error: falta tkinter (paquete python3-tk)" >&2
    return 1
  fi
  command -v ffmpeg &>/dev/null
}

# Conversión a M4A con ffmpeg (AAC). Compatible Debian 13+ sin faac.
# Uso: source lib/convert_m4a.sh

ffmpeg_to_m4a() {
  local input_file="$1"
  local output_file="$2"
  local bitrate_kbps="${3:-128}"

  if [ ! -f "$input_file" ]; then
    return 1
  fi

  ffmpeg -y -i "$input_file" \
    -map 0:a \
    -c:a aac \
    -b:a "${bitrate_kbps}k" \
    -map_metadata 0 -map_metadata 0:s:a:0 \
    -movflags +faststart \
    "$output_file" \
    -loglevel error 2>/dev/null
}

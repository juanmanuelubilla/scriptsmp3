# Conversión OGG → MP3 con ffmpeg (alternativa a oggdec|lame).
# Uso: source lib/convert_mp3.sh

ffmpeg_ogg_to_mp3() {
  local input_file="$1"
  local output_file="$2"
  local bitrate_kbps="${3:-128}"

  ffmpeg -y -i "$input_file" \
    -vn \
    -c:a libmp3lame \
    -b:a "${bitrate_kbps}k" \
    -id3v2_version 3 \
    "$output_file" \
    -loglevel error 2>/dev/null
}

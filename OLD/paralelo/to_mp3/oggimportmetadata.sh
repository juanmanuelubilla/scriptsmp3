#!/bin/bash

# Función para obtener la metadata de un archivo OGG utilizando vorbiscomment y guardarla en un archivo txt
get_metadata_ogg() {
    local file="$1"
    local txt_file="${file%.ogg}.txt"
    
    # Inicializamos el archivo .txt vacío
    > "$txt_file"
    
    # Extraemos la metadata relevante y la guardamos en un archivo .txt
    vorbiscomment -l "$file" | while IFS= read -r line; do
        case "$line" in
            ARTIST*) echo "ARTIST=${line#ARTIST=}" >> "$txt_file" ;;
            TITLE*) echo "TITLE=${line#TITLE=}" >> "$txt_file" ;;
            ALBUM*) echo "ALBUM=${line#ALBUM=}" >> "$txt_file" ;;
            TRACKNUMBER*) 
                # Extraemos solo el número de track, por ejemplo "1" de "1/10"
                track="${line#TRACKNUMBER=}"
                track="${track%%/*}"  # Eliminamos el "/x" para solo obtener el número
                echo "TRACKNUMBER=$track" >> "$txt_file"
                ;;
            DATE*) echo "YEAR=${line#DATE=}" >> "$txt_file" ;;
        esac
    done
}

# Función para agregar la metadata al archivo MP3 utilizando eyeD3 desde un archivo txt
add_mp3_metadata_from_txt() {
    local mp3_file="$1"
    local txt_file="${mp3_file%.mp3}.txt"
    
    # Leer el archivo txt y obtener los valores
    if [ -f "$txt_file" ]; then
        while IFS="=" read -r key value; do
            case $key in
                ARTIST) artist="$value" ;;
                TITLE) title="$value" ;;
                ALBUM) album="$value" ;;
                TRACKNUMBER) track="$value" ;;
                YEAR) year="$value" ;;
            esac
        done < "$txt_file"
        
        # Aseguramos que los valores no estén vacíos y asignamos valores predeterminados solo cuando corresponda
        [ -z "$track" ] && track=""
        [ -z "$artist" ] && artist=""
        [ -z "$title" ] && title=""   # Si está vacío, no lo asignamos
        [ -z "$album" ] && album=""
        [ -z "$year" ] && year=""
        
        # Usamos eyeD3 para agregar metadata solo si hay datos
        [ -n "$track" ] && eyeD3 --track "$track" "$mp3_file"
        [ -n "$artist" ] && eyeD3 --artist "$artist" "$mp3_file"
        [ -n "$title" ] && eyeD3 --title "$title" "$mp3_file"
        [ -n "$album" ] && eyeD3 --album "$album" "$mp3_file"
        [ -n "$year" ] && eyeD3 --release-year "$year" "$mp3_file"
        
        # Agregar imagen de portada (si existe)
        image="${mp3_file%.mp3}.jpg"
        if [ -f "$image" ]; then
            eyeD3 --add-image="$image:FRONT_COVER" "$mp3_file"
        fi
    else
        echo "Error: El archivo $txt_file no se encuentra."
    fi
}

# Ruta del directorio raíz donde se encuentran los archivos OGG
root_directory="$1"

# Verificar si vorbiscomment y eyeD3 están instalados
for cmd in vorbiscomment eyeD3; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd no está instalado. Instálalo primero."
        exit 1
    fi
done

# Buscar archivos OGG en el directorio raíz y subcarpetas y paralelizar el procesamiento
find "$root_directory" -type f -name "*.ogg" -print0 | \
xargs -0 -P "$(nproc)" -I {} bash -c '
    get_metadata_ogg() {
        local file="$1"
        local txt_file="${file%.ogg}.txt"
        > "$txt_file"
        vorbiscomment -l "$file" | while IFS= read -r line; do
            case "$line" in
                ARTIST*) echo "ARTIST=${line#ARTIST=}" >> "$txt_file" ;;
                TITLE*) echo "TITLE=${line#TITLE=}" >> "$txt_file" ;;
                ALBUM*) echo "ALBUM=${line#ALBUM=}" >> "$txt_file" ;;
                TRACKNUMBER*) track="${line#TRACKNUMBER=}"
                              track="${track%%/*}"
                              echo "TRACKNUMBER=$track" >> "$txt_file" ;;
                DATE*) echo "YEAR=${line#DATE=}" >> "$txt_file" ;;
            esac
        done
    }
    
    add_mp3_metadata_from_txt() {
        local mp3_file="$1"
        local txt_file="${mp3_file%.mp3}.txt"
        if [ -f "$txt_file" ]; then
            while IFS="=" read -r key value; do
                case $key in
                    ARTIST) artist="$value" ;;
                    TITLE) title="$value" ;;
                    ALBUM) album="$value" ;;
                    TRACKNUMBER) track="$value" ;;
                    YEAR) year="$value" ;;
                esac
            done < "$txt_file"
            
            [ -z "$track" ] && track=""
            [ -z "$artist" ] && artist=""
            [ -z "$title" ] && title=""
            [ -z "$album" ] && album=""
            [ -z "$year" ] && year=""
            
            [ -n "$track" ] && eyeD3 --track "$track" "$mp3_file"
            [ -n "$artist" ] && eyeD3 --artist "$artist" "$mp3_file"
            [ -n "$title" ] && eyeD3 --title "$title" "$mp3_file"
            [ -n "$album" ] && eyeD3 --album "$album" "$mp3_file"
            [ -n "$year" ] && eyeD3 --release-year "$year" "$mp3_file"
            
            image="${mp3_file%.mp3}.jpg"
            if [ -f "$image" ]; then
                eyeD3 --add-image="$image:FRONT_COVER" "$mp3_file"
            fi
        else
            echo "Error: El archivo $txt_file no se encuentra."
        fi
    }

    ogg_file="{}"
    get_metadata_ogg "$ogg_file"
    mp3_file="${ogg_file%.ogg}.mp3"
    if [ ! -f "$mp3_file" ]; then
        ffmpeg -i "$ogg_file" -codec:a libmp3lame -qscale:a 2 "$mp3_file"
    fi
    add_mp3_metadata_from_txt "$mp3_file"
'

# Eliminar los archivos .txt generados sin preguntar
find "$root_directory" -type f -name "*.txt" -exec rm -f {} \;
echo "Archivos .txt eliminados."

echo "Proceso completado."

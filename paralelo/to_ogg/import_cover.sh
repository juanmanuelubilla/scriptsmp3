#!/bin/bash

# Definir el directorio raíz (directorio base donde se encuentran los archivos .ogg y .jpg)
path="$1"

# Verificar si el directorio existe
if [ ! -d "$path" ]; then
    echo "El directorio no existe: $path"
    exit 1
fi

# Crear un archivo de log con el nombre que desees
log_file="$path/command_log.txt"
> "$log_file"  # Limpiar el archivo de log si ya existe

# Crear un archivo de texto para guardar los paths completos
paths_file="$path/paths.txt"
> "$paths_file"  # Limpiar el archivo de paths si ya existe

# Extraer los dos primeros caracteres del directorio raíz
prefix=${path:0:2}

# Contar cuántos archivos .ogg existen
total_files=$(find "$path" -type f -name "*.ogg" | wc -l)
echo "Total de archivos .ogg encontrados: $total_files"

# Buscar archivos .ogg en todas las subcarpetas y recorrerlos
find "$path" -type f -name "*.ogg" -print0 | while IFS= read -r -d '' ogg_file; do
    # Verificar si el path comienza con "/". Si no, agregar el prefijo.
    if [[ "${ogg_file:0:1}" != "/" ]]; then
        ogg_file="$prefix$ogg_file"
    fi
    
    # Guardar el path completo en el archivo de texto
    echo "$ogg_file" >> "$paths_file"

    # Crear la variable con el nombre del archivo de portada .jpg
    jpg_file="${ogg_file%.ogg}.jpg"

    # Crear el archivo temporal para el resultado
    temp_file="${ogg_file%.ogg}_temp.ogg"

    # Comando de ffmpeg que se ejecutará
    ffmpeg_command="ffmpeg -y -i \"$ogg_file\" -i \"$jpg_file\" -c:a copy -id3v2_version 3 -metadata:s:v title=\"Portada\" -metadata:s:v comment=\"Imagen de portada\" \"$temp_file\""
    
    # Guardar el comando ejecutado en el archivo de log
    echo "$ffmpeg_command" >> "$log_file"

    # Ejecutar el comando ffmpeg sin guardar log
    eval "$ffmpeg_command"

    # Si el comando fue exitoso, reemplazar el archivo original con el archivo temporal
    if [ $? -eq 0 ]; then
        mv -f "$temp_file" "$ogg_file"  # Reemplazar el archivo original .ogg
        rm "$jpg_file"  # Eliminar el archivo de portada .jpg (aunque no se haya encontrado)
        echo "Portada añadida exitosamente a: $ogg_file"
        echo "Archivo de portada eliminado: $jpg_file"
    else
        echo "Error al procesar el archivo: $ogg_file"
    fi
done

# Contar el número de archivos procesados
processed_files=$(find "$path" -type f -name "*.ogg" | wc -l)
echo "Archivos procesados: $processed_files de $total_files"

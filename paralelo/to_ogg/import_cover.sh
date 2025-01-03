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

# Crear archivos para guardar los paths completos y relativos
paths_file="$path/paths.txt"
relative_paths_file="$path/relative_paths.txt"
> "$paths_file"  # Limpiar el archivo de paths completos si ya existe
> "$relative_paths_file"  # Limpiar el archivo de paths relativos si ya existe

# Contar cuántos archivos .ogg existen
total_files=$(find "$path" -type f -name "*.ogg" | wc -l)
echo "Total de archivos .ogg encontrados: $total_files"

# Buscar archivos .ogg en todas las subcarpetas y recorrerlos
find "$path" -type f -name "*.ogg" -print0 | while IFS= read -r -d '' ogg_file; do
    # Obtener la ruta relativa eliminando la parte común ($path)
    relative_path="${ogg_file#"$path/"}"
    
    # Concatenar la ruta base con la ruta relativa para obtener la ruta completa
    full_ogg_file="$path/$relative_path"

    # Guardar el path completo en el archivo de texto
    echo "$full_ogg_file" >> "$paths_file"

    # Guardar el path relativo en el archivo de texto
    echo "$relative_path" >> "$relative_paths_file"

    # Crear la variable con el nombre del archivo de portada .jpg (con ruta completa)
    jpg_file="${full_ogg_file%.ogg}.jpg"

    # Crear el archivo temporal para el resultado
    temp_file="${full_ogg_file%.ogg}_temp.ogg"

    # Comando de ffmpeg que se ejecutará
    ffmpeg_command="ffmpeg -y -i \"$full_ogg_file\" -i \"$jpg_file\" -c:a copy -id3v2_version 3 -metadata:s:v title=\"Portada\" -metadata:s:v comment=\"Imagen de portada\" \"$temp_file\""
    
    # Guardar el comando ejecutado en el archivo de log
    echo "$ffmpeg_command" >> "$log_file"

    # Ejecutar el comando ffmpeg sin guardar log
    eval "$ffmpeg_command"

    # Si el comando fue exitoso, reemplazar el archivo original con el archivo temporal
    if [ $? -eq 0 ]; then
        mv -f "$temp_file" "$full_ogg_file"  # Reemplazar el archivo original .ogg
        rm "$jpg_file"  # Eliminar el archivo de portada .jpg (aunque no se haya encontrado)
        echo "Portada añadida exitosamente a: $full_ogg_file"
        echo "Archivo de portada eliminado: $jpg_file"
    else
        echo "Error al procesar el archivo: $full_ogg_file"
    fi
done

# Contar el número de archivos procesados
processed_files=$(find "$path" -type f -name "*.ogg" | wc -l)
echo "Archivos procesados: $processed_files de $total_files"

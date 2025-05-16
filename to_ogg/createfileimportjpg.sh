#!/bin/bash

# Directorio a recorrer, tomado del primer argumento ($1)
DIRECTORIO="$1"

# Verificar si el directorio fue proporcionado
if [ -z "$DIRECTORIO" ]; then
    echo "Por favor, proporciona un directorio como argumento."
    exit 1
fi

# Buscar todos los archivos OGG en el directorio y subdirectorios
find "$DIRECTORIO" -type f -name "*.ogg" | while read archivo_ogg; do
    # Crear una nueva variable para la ruta del archivo OGG
    archivo_ogg_path="$archivo_ogg"
    
    # Crear la variable con el nombre del archivo .ogg reemplazado por .jpg
    archivo_jpg="${archivo_ogg_path%.ogg}.jpg"
    
    # Verificar si el archivo JPG existe antes de intentar importarlo
    if [ -f "$archivo_jpg" ]; then
        # Usar el comando kid3-cli para importar la imagen al archivo OGG
        if kid3-cli -c "select all" -c 'set picture:\"$archivo_jpg\" ""' "$archivo_ogg_path"; then
	    echo "Imagen $archivo_jpg importada correctamente al archivo $archivo_ogg_path"
            
            # Eliminar el archivo JPG después de la importación exitosa
            rm "$archivo_jpg"
        else
            echo "Error al importar la imagen $archivo_jpg al archivo $archivo_ogg_path"
        fi
    else
        echo "El archivo JPG $archivo_jpg no existe para el archivo OGG $archivo_ogg_path"
    fi
done


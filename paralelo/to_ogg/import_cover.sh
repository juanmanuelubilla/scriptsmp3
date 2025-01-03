#!/bin/bash

# Directorio pasado como argumento
directorio="$1"

# Verificar si se pasó un directorio
if [ -z "$directorio" ]; then
    echo "Por favor, proporciona un directorio como argumento."
    exit 1
fi

# Verificar si el directorio es válido
if [ ! -d "$directorio" ]; then
    echo "El directorio proporcionado no es válido."
    exit 1
fi

# Archivo de log donde guardaremos los comandos ejecutados y los resultados
log_file="$directorio/comandos_ejecutados.txt"

# Crear o limpiar el archivo de log
echo "" > "$log_file"

# Función para imprimir en color rojo
print_error() {
    echo -e "\033[31m$1\033[0m"
    echo "$1" >> "$log_file"  # Guardar en el log de errores
}

# Función para imprimir en color verde
print_success() {
    echo -e "\033[32m$1\033[0m"
    echo "$1" >> "$log_file"  # Guardar en el log de éxitos
}

# Recorrer el directorio y sus subdirectorios buscando archivos .ogg
find "$directorio" -type f -iname "*.ogg" | sort | \
while read archivo_ogg; do
    # Obtener el nombre base del archivo OGG (sin la extensión)
    nombre_sin_extension=$(basename "$archivo_ogg" .ogg)
    
    # Crear el nombre del archivo JPG con el mismo nombre base que el OGG
    archivo_jpg="${archivo_ogg%.ogg}.jpg"
    
    # Verificar si el archivo JPG existe
    if [ -f "$archivo_jpg" ]; then
        # Registrar el comando kid3-cli en el archivo de log
        comando="kid3-cli -c \"select all\" -c 'set picture:\"$archivo_jpg\" \"\"' \"$archivo_ogg\""
        echo "$comando" >> "$log_file"
        
        # Ejecutar kid3-cli para agregar la carátula al archivo OGG
        if kid3-cli -c "select all" -c "set picture:\"$archivo_jpg\" \"\" \"$archivo_ogg\""; then
            # Si la operación fue exitosa
            print_success "Éxito: Carátula agregada a '$archivo_ogg'."
        else
            # Si la operación falló
            print_error "Error: No se pudo agregar la carátula a '$archivo_ogg'."
        fi

        # Eliminar el archivo JPG tras agregar la carátula
        rm "$archivo_jpg"
    else
        # Si no se encuentra el archivo JPG correspondiente
        print_error "Error: No se encontró el archivo JPG para '$archivo_ogg'."
    fi
done

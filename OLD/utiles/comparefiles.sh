#!/bin/bash

# Uso: ./sync_audio_fixed.sh <PATH1> <PATH2> <PATH3> <EXTENSION>

# Verificar que se hayan pasado cuatro argumentos
if [[ $# -ne 4 ]]; then
    echo "Uso: $0 <PATH1> <PATH2> <PATH3> <EXTENSION>"
    exit 1
fi

# Rutas de entrada y salida basadas en los argumentos
PATH1="$1"
PATH2="$2"
PATH3="$3"
EXTENSION="$4"

# Crear estructura de directorios basada en PATH1 y PATH2
echo "Creando estructura de carpetas en $PATH3..."
find "$PATH1" "$PATH2" -type d | while read -r dir; do
    relative_dir="${dir#$PATH1}"  # Eliminar prefijo PATH1
    relative_dir="${relative_dir#$PATH2}"  # Eliminar prefijo PATH2
    mkdir -p "$PATH3/$relative_dir"
done

# Función para elegir el archivo más antiguo entre dos
choose_oldest_file() {
    local file1="$1"
    local file2="$2"

    if [[ -f "$file1" && -f "$file2" ]]; then
        if [[ "$file1" -ot "$file2" ]]; then
            echo "$file1"
        else
            echo "$file2"
        fi
    fi
}

# Función para copiar archivos únicos o similares
copy_files() {
    local src="$1"
    local dest="$2"
    local other_src="$3"

    echo "Procesando archivos desde $src..."
    find "$src" -type f -name "*.$EXTENSION" | while read -r file; do
        relative_path="${file#$src}"
        dest_file="$dest$relative_path"
        file_in_other_src="$other_src$relative_path"

        # Si el archivo ya existe en el destino, decidir cuál conservar
        if [[ -f "$dest_file" ]]; then
            oldest_file=$(choose_oldest_file "$file" "$dest_file")
            if [[ "$oldest_file" == "$file" ]]; then
                echo "Reemplazando archivo existente: $dest_file con $file"
                cp "$file" "$dest_file"
            fi
        elif [[ -f "$file_in_other_src" ]]; then
            # Si hay un archivo similar en el otro origen, elegir el más antiguo
            oldest_file=$(choose_oldest_file "$file" "$file_in_other_src")
            mkdir -p "$(dirname "$dest_file")"
            echo "Archivo similar encontrado en ambos: copiando el más antiguo $oldest_file a $dest_file"
            cp "$oldest_file" "$dest_file"
        else
            # Copiar directamente si no hay conflictos
            mkdir -p "$(dirname "$dest_file")"
            echo "Copiando archivo único: $file a $dest_file"
            cp "$file" "$dest_file"
        fi
    done
}

# Copiar archivos desde PATH1 y PATH2, comparando entre ellos
copy_files "$PATH1" "$PATH3" "$PATH2"
copy_files "$PATH2" "$PATH3" "$PATH1"

echo "Proceso completado. Archivos copiados a $PATH3."

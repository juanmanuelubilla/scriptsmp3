#!/bin/bash

# Registrar el tiempo inicial
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m|     RENOMBRANDO NUMERACION DE TRACKS         |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

# Verifica si se proporcionó el path de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 <path>"
    exit 1
fi

# Directorio base
dir="$1"

# Verifica si el directorio existe
if [ ! -d "$dir" ]; then
    echo -e "\033[1;33mError: El directorio '$dir' no existe.\033[0m"
    exit 1
fi

# Contar los archivos .ogg
total_files=$(find "$dir" -type f -name "*.ogg" | wc -l)
current_file=0
error_occurred=0

# Función para mostrar la barra de progreso
function show_progress {
    local progress=$1
    local total=$2
    local percent=$((progress * 100 / total))
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))
    local empty_length=$((bar_length - filled_length))
    local bar=$(printf "%-${filled_length}s" "#" | tr ' ' '#')
    local empty=$(printf "%-${empty_length}s" " " | tr ' ' ' ')
    echo -ne "[$bar$empty] $percent% ($progress/$total) \r"
}

# Buscar archivos .ogg y renombrarlos si es necesario
find "$dir" -type f -name "*.ogg" | while read -r file; do
    # Obtener el nombre del archivo sin la ruta
    filename=$(basename "$file")

    newname="$filename"

    # (1) Si empieza con un número del 1 al 9 seguido de " -", añadir un cero adelante
    if [[ "$filename" =~ ^([1-9])\ -.*\.ogg$ ]]; then
        newname="0${BASH_REMATCH[1]} -${filename:3}"
    fi

    # (2) Si tiene dos dígitos seguidos de un espacio sin "-", agregar " - "
    if [[ "$filename" =~ ^([0-9]{2})\ ([^ -].*\.ogg)$ ]]; then
        newname="${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}"
    fi

    # (3) Si el tercer carácter es "." y el cuarto no es un espacio, reemplazar "." por " - "
    if [[ "$filename" =~ ^([0-9]{2})\.(.*\.ogg)$ ]]; then
        newname="${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}"
    fi

    # (4) Si el tercer y cuarto carácter son "- " y el quinto no es un espacio, reemplazar "- " por " - "
    if [[ "$filename" =~ ^([0-9]{2})-([ ]?)(.*\.ogg)$ ]]; then
        newname="${BASH_REMATCH[1]} - ${BASH_REMATCH[3]}"
    fi

    # (5) Si tiene el formato "[01] juanmanuel", eliminar los corchetes y agregar " -"
    if [[ "$filename" =~ ^\([0-9]{2}\)(.*\.ogg)$ ]]; then
        newname="${BASH_REMATCH[1]}"
        newname="00 - ${newname:3}"  # Agregar el " -"
    fi

    # (6) Si el archivo empieza con un número del 1 al 9 seguido de "-", agregar un 0 al principio
    if [[ "$filename" =~ ^([1-9])-\ (.*\.ogg)$ ]]; then
        newname="0${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}"
    fi

     # (7) Si el tercer carácter es una letra, agregar " - "
    if [[ "$filename" =~ ^([0-9]{2})([a-zA-Z])(.*\.ogg)$ ]]; then
        newname="${BASH_REMATCH[1]} - ${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    fi

   # Renombrar el archivo si se cambió el nombre
    if [[ "$newname" != "$filename" ]]; then
        mv "$file" "$(dirname "$file")/$newname"
        if [ $? -ne 0 ]; then
            error_occurred=1
        fi
    fi

    # Actualizar el progreso
    current_file=$((current_file + 1))
    
    # Mostrar la barra de progreso
    show_progress $current_file $total_files
done

# Al finalizar, mostrar mensaje de error si hubo algún problema
echo -e "\n" # Para mover la línea a una nueva
if [ "$error_occurred" -eq 1 ]; then
    echo -e "\033[1;31mHubo un error durante el renombrado de algunos archivos.\033[0m"
fi

# Calcular tiempo final y duración total
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

# Mostrar tiempo total de ejecución
echo "Duracion del proceso de remombrado: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"

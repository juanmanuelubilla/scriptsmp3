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

# Buscar archivos .ogg que empiecen con 1-, 2-, ..., 9-
find "$dir" -type f -name "*.ogg" | while read -r file; do
    # Obtener el nombre del archivo sin la ruta
    filename=$(basename "$file")

    # Verificar si el nombre empieza con un número entre 1 y 9 seguido de " -"
    if [[ "$filename" =~ ^([1-9])\ -.*\.ogg$ ]]; then
        # Agregar un cero al número
        newname="0${BASH_REMATCH[1]} -${filename:3}"
        mv "$file" "$(dirname "$file")/$newname"
        # Si hay un error al renombrar, marcar error_occurred
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
#echo ""

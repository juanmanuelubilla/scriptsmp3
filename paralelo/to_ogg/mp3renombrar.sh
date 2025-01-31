#!/bin/bash

# Registrar el tiempo inicial
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo -e "\033[1;36m| RENOMBRANDO ARCHIVOS CON CARACTERES RAROS... |\033[0m"
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""


# Verifica si se proporcionó el path de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 <path>"
    exit 1
fi

# Directorio base
base_path="$1"

# Verifica si el directorio existe
if [ ! -d "$base_path" ]; then
    echo -e "\033[1;33mError: El directorio '$base_path' no existe.\033[0m"
    exit 1
fi

# Función para limpiar nombres
clean_name() {
    local original_name="$1"
    local dir_name
    local base_name
    local cleaned_name

    dir_name=$(dirname "$original_name")
    base_name=$(basename "$original_name")

    # Reemplazar acentos por vocales sin acento
    cleaned_name=$(echo "$base_name" | sed -e 'y/áéíóúÁÉÍÓÚ/aeiouAEIOU/')

    # Eliminar caracteres no imprimibles y problemáticos, excepto espacios, puntos, guiones y guiones bajos
    cleaned_name=$(echo "$cleaned_name" | tr -cd '[:alnum:][:space:]._-')

    # Renombrar si el nombre fue modificado
    if [ "$base_name" != "$cleaned_name" ]; then
        mv -n "$original_name" "$dir_name/$cleaned_name" 2>/dev/null
        if [ $? -ne 0 ]; then
            error_messages+=("\033[1;31mError al renombrar: '$original_name'\033[0m")
        fi
    fi
}

# Contamos el total de archivos para la barra de progreso
total_files=$(find "$base_path" -type f | wc -l)

# Si no hay archivos, salimos
if [ "$total_files" -eq 0 ]; then
    echo -e "\033[1;33mNo se encontraron archivos para procesar.\033[0m"
    exit 0
fi

# Inicializar contador de progreso y arreglo de errores
processed_files=0
declare -a error_messages

# Mostrar la barra de progreso
echo -n "Procesando archivos: ["

# Recorrer el directorio y procesar nombres de archivos y carpetas sin usar un subshell
while IFS= read -r -d '' path; do
    clean_name "$path"
    
    # Incrementar el contador de archivos procesados
    ((processed_files++))
    
    # Calcular el porcentaje
    percent=$(( (processed_files * 100) / total_files ))

    # Limitar el porcentaje a 100% máximo
    if [ "$percent" -gt 100 ]; then
        percent=100
    fi

    # Mostrar la barra de progreso y los archivos procesados
    progress=$(printf "%-${percent}s" "#" | tr " " "#")
    echo -ne "\rProcesando archivos: [${progress}$(printf "%-$((100-percent))s" " ")] $percent% (${processed_files}/${total_files})"
done < <(find "$base_path" -depth -print0)

# Terminar la barra de progreso
echo -e "\n"

# Mostrar los errores si los hubo
for error in "${error_messages[@]}"; do
    echo -e "$error"
done

# Calcular tiempo final y duración total
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

# Mostrar tiempo total de ejecución
echo "Duracion del proceso de remombrado: ${minutes}m ${seconds}s"
echo ""
echo -e "\033[1;36m+----------------------------------------------+\033[0m"
echo ""

#!/bin/bash

# Registrar tiempo de inicio
start_time=$(date +%s)

echo ""
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo -e "\033[1;36m|        CONVIRTIENDO ARCHIVOS DE OGG A M4A       |\033[0m"
echo -e "\033[1;36m+-------------------------------------------------+\033[0m"
echo ""

# Directorio raíz desde donde se buscarán los archivos OGG
root_directory="$1"

# Calidad de la conversión, por defecto 128 si no se pasa como argumento
quality="${2:-128}"

# Verificación de argumento de directorio
if [ -z "$root_directory" ]; then
    echo "Uso: $0 <directorio> [calidad (64|128|192|256|320)]"
    exit 1
fi

# Verificar que el directorio existe
if [ ! -d "$root_directory" ]; then
    echo "Error: El directorio '$root_directory' no existe."
    exit 1
fi

# Función para convertir un archivo OGG a M4A con la calidad indicada
convert_to_m4a() {
    input_file="$1"
    output_file="${input_file%.ogg}.m4a"

    if oggdec -o - "$input_file" 2>/dev/null | faac -b "$quality" -o "$output_file" - >/dev/null 2>&1; then
        echo -e "\033[1;32m[OK] Conversión exitosa: $input_file\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Falló la conversión: $input_file\033[0m"
    fi
}

export -f convert_to_m4a
export quality

# Detectar cantidad de núcleos/hilos disponibles
nproc=$(nproc)

# Ejecutar conversiones en paralelo
find "$root_directory" -type f -name "*.ogg" -print0 | \
xargs -0 -n 1 -P "$nproc" bash -c 'convert_to_m4a "$0"'

# Calcular y mostrar duración
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo -e "\033[1;36mConversión completada en ${minutes}m ${seconds}s usando $nproc procesos paralelos (bitrate: ${quality}).\033[0m"

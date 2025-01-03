param (
    [string]$parametro1
)

write-host "GUARDANDO ARCHIVO EN: $parametro1"

$PATHDESTINATION = $parametro1

# Contar archivos OGG
try {
    $oggFiles = Get-ChildItem $PATHDESTINATION -Recurse -Include *.ogg -ErrorAction Stop
    $totalFiles = $oggFiles.Count
    if ($totalFiles -eq 0) {
        throw "No se encontraron archivos OGG en el directorio especificado."
    }
    write-host "Total de archivos OGG encontrados: $totalFiles"
} catch {
    write-host "Error: $_"
    exit 1
}

# Detectar hilos disponibles
try {
    $availableThreads = [Environment]::ProcessorCount
    if ($availableThreads -eq 0) {
        throw "No se detectaron hilos disponibles en el sistema."
    }
    write-host "Hilos disponibles: $availableThreads"
} catch {
    write-host "Error: $_"
    exit 1
}

# Calcular archivos por hilo
$filesPerThread = [math]::Ceiling($totalFiles / $availableThreads)
write-host "Archivos por hilo: $filesPerThread"

# Crear scripts por cada bloque de archivos
for ($i = 0; $i -lt $availableThreads; $i++) {
    $startIndex = $i * $filesPerThread
    $endIndex = [math]::Min(($startIndex + $filesPerThread - 1), ($totalFiles - 1))
    
    if ($startIndex -ge $totalFiles) {
        break
    }

    $scriptPath = "$PATHDESTINATION/IMPORTALBUMCOVER_$($i + 1).sh"
    try {
        New-Item -Path $scriptPath -ItemType File -Force | Out-Null
        write-host "Creando archivo: ${scriptPath}"
    } catch {
        write-host "Error al crear el archivo ${scriptPath}: $_"
        continue
    }

    # Procesar archivos del bloque
    for ($j = $startIndex; $j -le $endIndex; $j++) {
        $file = $oggFiles[$j]
        $folderemp3 = $file.DirectoryName
        $baseName = $file.BaseName
        
        # Definir el archivo temporal con _tmp en lugar de .tmp
        $temp_file = "$($file.DirectoryName)/$($baseName)_tmp.ogg"
        
        # Definir el archivo de destino completo
        $full_ogg_file = "$($file.DirectoryName)/$($baseName).ogg"

        # Comando para copiar el archivo original al nuevo archivo temporal
        $copytmp = "sudo cp '$($file.FullName)' '$($temp_file)'"

        # Comando para mover el archivo temporal al archivo original
        $movetmp = "sudo mv -f '$temp_file' '$full_ogg_file'"

        # Comando para importar la portada usando ffmpeg
        $importcover = 'ffmpeg -y -i "' + $($file.FullName) + '" -i "' + $($folderemp3) + '/' + $($baseName) + '.jpg" -c:a copy -id3v2_version 3 -metadata:s:v title="Portada" -metadata:s:v comment="Imagen de portada" "' + $($temp_file) + '"'

        # Echo para mostrar que se ha importado la portada
        $echoCommand = "echo COVER IMPORTADO: '$($folderemp3)/$($baseName).jpg'"

        # Comando para eliminar la portada
        $removeCommand = "sudo rm '$($folderemp3)/$($baseName).jpg'"

        # Crear la línea de comandos para el script
        
        $scriptLine = "if $copytmp && $importcover; then echo 'COVER IMPORTADO: $($folderemp3)/$($baseName).jpg'; sudo rm '$($folderemp3)/$($baseName).jpg' && sudo mv -f '$($temp_file)' '$($file.FullName)'; else echo 'Error al agregar caratula: $($folderemp3)/$($baseName).jpg' >&2; fi"
        #$scriptLine = "$copytmp && $importcover && $echoCommand && $removeCommand && $movetmp"

        # Agregar los comandos al archivo del script
        try {
            Add-Content -Path $scriptPath -Value $scriptLine
        } catch {
            write-host "Error al agregar comandos al archivo ${scriptPath}: $_"
            break
        }
    }
}

write-host "Todos los scripts han sido generados exitosamente."

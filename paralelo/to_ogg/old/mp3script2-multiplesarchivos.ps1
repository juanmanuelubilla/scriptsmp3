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

        # Mantener el formato original de $importcover
        $importcover1 = 'kid3-cli -c "select all" -c ''set picture:'
        $importcover2 = '"' + $folderemp3 + '/' + $baseName + '.jpg" ""'' "' + $file.FullName + '"'
        $importcover = "$importcover1$importcover2"

        $echoCommand = "echo COVER IMPORTADO: '$folderemp3/$baseName.jpg'"
        $removeCommand = "sudo rm '$folderemp3/$baseName.jpg'"

        $scriptLine = "$importcover && $echoCommand && $removeCommand"
        #$scriptLine = $importcover

        # Agregar comandos al script
        try {
            Add-Content -Path $scriptPath -Value $scriptLine
        } catch {
            write-host "Error al agregar comandos al archivo ${scriptPath}: $_"
            break
        }
    }
}

write-host "Todos los scripts han sido generados exitosamente."


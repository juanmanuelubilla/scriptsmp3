param ( [string]$parametro1 )

write-host "GUARDANDO ARCHIVO EN: $parametro1"

#$EJECUCION = $env:BUILD_NUMBER
#$EJECUCION = $EJECUCION - 1
$PATH = "IMPORTALBUMCOVER.sh"
$PATHDESTINATION = $parametro1
#$PATHDESTINATION = "x:\SPOTIFY\TEMP"
#$RENAMEFILE = "IMPORTALBUMCOVER.sh"
#$RENAMEFILE = "IMPORTALBUMCOVER-$EJECUCION.sh"
$NEWPATH = "$PATHDESTINATION/$PATH"
write-host $NEWPATH

$ExisteFile = Test-Path $NEWPATH
If ($ExisteFile -eq $True) {
    Remove-Item -Path $NEWPATH -Force | Out-Null
}
New-Item -Path $NEWPATH -ItemType File | Out-Null

$findmp3folder = Get-ChildItem $PATHDESTINATION -Recurse -Include *.ogg #| select * 
#write-host $findmp3
foreach ($findmp3folders in $findmp3folder) { 
    $subfoldermp3 = $findmp3folders.name
    $namemp3 = $findmp3folders.BaseName
    #write-host $subfoldermp3
    $folderemp3 = $findmp3folders.Directory
    #write-host $folderemp3
    #kid3-cli -c "select all" -c 'set picture:"cover.jpg" ""' "./*.ogg"   
    $importcover1 =  'kid3-cli -c "select all" -c ''set picture:'
    $importcover2 = '"' + $folderemp3 + '/' + $findmp3folders.BaseName + '.jpg" ""'' "' + $findmp3folders.FullName + '"'
    #$importcover2 = '"' + $folderemp3 + '/' + $findmp3folders.BaseName + '.jpg" ""'' "' + $findmp3folders.Directory + '/*.ogg"'
    $importcover = "$importcover1$importcover2"
    write-host $importcover
    #Add-Content -Path $NEWPATH -Value $importcover
  
    #$comando1 = "echo COVER IMPORTADO: $findmp3folders.4028Directory/$findmp3folders.BaseName.jpg"
    $comando1 = "echo 'COVER IMPORTADO: $folderemp3/$namemp3.jpg'"
    #Add-Content -Path $NEWPATH -Value $comando1 
    
    #$comando2 = "sudo rm '$findmp3folders.Directory$findmp3folders.BaseName.jpg'"
    $comando2 = "sudo rm '$folderemp3/$namemp3.jpg'"
    #write-host $comando2
    #Add-Content -Path $NEWPATH -Value $comando2 

    #$scriptLine = "$importcover && $comando1 && $comando2"
    #Add-Content -Path $NEWPATH -Value $scriptLine
    
    $scriptLine = "
if $importcover; then
    $comando1
    $comando2
else
    echo -e '\033[1;31mError al importar la portada: $folderemp3/$namemp3.jpg\033[0m'

fi"
    Add-Content -Path $NEWPATH -Value $scriptLine
}

#Rename-Item -Path "$PATHDESTINATION/IMPORTALBUMCOVER.sh" -NewName "$PATHDESTINATION/$RENAMEFILE"
#Copy-Item –Path $PATH –Destination $PATHDESTINATION


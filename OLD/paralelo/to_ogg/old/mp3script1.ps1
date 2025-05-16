#$EJECUCION = $env:BUILD_NUMBER
#$EJECUCION = $EJECUCION - 1
#$PATH = "/$ENV:WORKSPACE/EXTRACTALBUMCOVER.sh"
$PATH = "EXTRACTALBUMCOVER.sh"
$PATHDESTINATION = "/mnt/R1/HDD500GB/SPOTIFY/TEMP/"
#$PATHDESTINATION = "x:\SPOTIFY\TEMP\"
$RENAMEFILE = "EXTRACTALBUMCOVER.sh"
#$RENAMEFILE = "EXTRACTALBUMCOVER-$EJECUCION.sh"
$NEWPATH = "$PATHDESTINATION/$PATH"
#write-host $NEWPATH


$ExisteFile = Test-Path $NEWPATH
If ($ExisteFile -eq $True) {
    Remove-Item -Path $NEWPATH -Force | Out-Null
}

New-Item -Path $NEWPATH -ItemType File | Out-Null

$findmp3folder = Get-ChildItem $PATHDESTINATION -Recurse -Include *.mp3 #| select *  
foreach ( $findmp3folders in $findmp3folder) {
    $archivo = $findmp3folders.FullName

    #eyeD3 --write-images=./ '1 - Reina.mp3'
    $comandoextract1 = "eyeD3 --write-images='" + $findmp3folders.Directory + "' "
    $comandoextract2 = "'$archivo'"
    $comandoextract = "$comandoextract1$comandoextract2"
    write-host $comandoextract
    Add-Content -Path $NEWPATH -Value $comandoextract

    #mv nombreviejoarchivo1 nombrenuevoarchivo1
    #$comando1 = "sudo mv '" + $findmp3s.Directory + "/FRONT_COVER.None' '" + $findmp3s.Directory + "/cover.jpg'"
    $comando1 = "sudo mv '" + $findmp3folders.Directory + "/FRONT_COVER.None' '" + $findmp3folders.Directory + "/" + $findmp3folders.BaseName +".jpg'`n"
    write-host $comando1
    Add-Content -Path $NEWPATH -Value $comando1

    $comando1 = "sudo mv '" + $findmp3folders.Directory + "/FRONT_COVER.png' '" + $findmp3folders.Directory + "/" + $findmp3folders.BaseName +".png'`n"
    write-host $comando1
    Add-Content -Path $NEWPATH -Value $comando1
}

$findmp3folder = Get-ChildItem $PATHDESTINATION -recurse -Directory
#$findmp3folder = Get-ChildItem "x:\SPOTIFY\TEMP\" -recurse -Directory | select * 
#write-host $findmp3
foreach ( $findmp3folders in $findmp3folder) { 
    $subfoldermp3 = $findmp3folders.FullName
    write-host "FOLDER1" + $subfoldermp3
    $folderemp3 = $PATHDESTINATION + $subfoldermp3
    $folderemp3 = $subfoldermp3
    #write-host $folderemp3
    $findmp3cover = Get-ChildItem $folderemp3 -Recurse -Include *.mp3 | Select-Object -last 1  
    foreach ( $findmp3covers in $findmp3cover) {
        $archivo = $findmp3covers.FullName

        #eyeD3 --write-images=./ '1 - Reina.mp3'
        $comandoextract1 = "eyeD3 --write-images='" + $findmp3covers.Directory + "' "
        $comandoextract2 = "'$archivo'"
        $comandoextract = "$comandoextract1$comandoextract2"
        write-host $comandoextract
        Add-Content -Path $NEWPATH -Value $comandoextract

        #mv nombreviejoarchivo1 nombrenuevoarchivo1
        $comando1 = "sudo mv '" + $findmp3covers.Directory + "/FRONT_COVER.None' '" + $findmp3covers.Directory + "/cover.jpg'`n"
        write-host $comando1
        Add-Content -Path $NEWPATH -Value $comando1

        #mv nombreviejoarchivo1 nombrenuevoarchivo1
        $comando1 = "sudo mv '" + $findmp3covers.Directory + "/FRONT_COVER.png' '" + $findmp3covers.Directory + "/cover.png'`n"
        write-host $comando1
        Add-Content -Path $NEWPATH -Value $comando1
     }
}

#Rename-Item -Path "$PATHDESTINATION/EXTRACTALBUMCOVER.sh" -NewName "$PATHDESTINATION/$RENAMEFILE"
#Copy-Item –Path $PATH –Destination $PATHDESTINATION

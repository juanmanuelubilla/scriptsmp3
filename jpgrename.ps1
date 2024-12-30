param ( [string]$parametro1 )

$Destination = "$parametro1"

write-host "RENOMBRANDO ARCHIVOS EN $parametro1"

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '1 -','01 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '2 -','02 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '3 -','03 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '4 -','04 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '5 -','05 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '6 -','06 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '7 -','07 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '8 -','08 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '9 -','09 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '101 -','11 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '102 -','12 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '103 -','13 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '104 -','14 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '105 -','15 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '106 -','16 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '107 -','17 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '108 -','18 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '109 -','19 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '201 -','21 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '202 -','22 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '203 -','23 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '204 -','24 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '205 -','25 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '206 -','26 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '207 -','27 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '208 -','28 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '209 -','29 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '301 -','31 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '302 -','32 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '303 -','33 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '304 -','34 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '305 -','35 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '306 -','36 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '307 -','37 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '308 -','38 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '309 -','39 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '401 -','41 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '402 -','42 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '403 -','43 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '404 -','44 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '405 -','45 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '406 -','46 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '407 -','47 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '408 -','48 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '409 -','49 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '501 -','51 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '502 -','52 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '503 -','53 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '504 -','54 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '505 -','55 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '506 -','56 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '507 -','57 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '508 -','58 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '509 -','59 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '601 -','61 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '602 -','62 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '603 -','63 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '604 -','64 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '605 -','65 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '606 -','66 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '607 -','67 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '608 -','68 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '609 -','69 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '701 -','71 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '702 -','72 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '703 -','73 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '704 -','74 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '705 -','75 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '706 -','76 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '707 -','77 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '708 -','78 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '709 -','79 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '801 -','81 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '802 -','82 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '803 -','83 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '804 -','84 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '805 -','85 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '806 -','86 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '807 -','87 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '808 -','88 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '809 -','89 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '901 -','91 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '902 -','92 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '903 -','93 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '904 -','94 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '905 -','95 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '906 -','96 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '907 -','97 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '908 -','98 -'}

Get-ChildItem $Destination -Filter "*.jpg" -Recurse | 
    Rename-Item -NewName {$_.Name -replace '909 -','99 -'}


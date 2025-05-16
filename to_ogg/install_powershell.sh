#!/bin/bash

# Función para detectar la arquitectura del procesador
detect_architecture() {
    arch=$(uname -m)
    case "$arch" in
        armv7l|armhf|aarch64)
            echo "Raspberry (ARM)"
            ;;
        x86_64|amd64)
            echo "AMD/Intel (x86_64)"
            ;;
        *)
            echo "Arquitectura desconocida: $arch"
            exit 1
            ;;
    esac
}

# Verificar si PowerShell está instalado
check_powershell() {
    if command -v pwsh >/dev/null 2>&1; then
        echo "PowerShell está instalado."
        version=$(pwsh -Command '$PSVersionTable.PSVersion | ForEach-Object { "$($_.Major).$($_.Minor).$($_.Patch)" }')
        echo "Versión de PowerShell: $version"
    else
        echo "PowerShell no está instalado."
        install_powershell
    fi
}

# Instalar PowerShell según la arquitectura
install_powershell() {
    arch=$(uname -m)
    
    if [[ "$arch" == "armv7l" || "$arch" == "armhf" || "$arch" == "aarch64" ]]; then
        # Instalación para Raspberry Pi (ARM)
        echo "Instalando PowerShell para Raspberry Pi (ARM)..."
        sudo apt-get update -y
        sudo apt-get install -y wget apt-transport-https software-properties-common
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update -y
        sudo apt-get install -y powershell
    elif [[ "$arch" == "x86_64" || "$arch" == "amd64" ]]; then
        # Instalación para AMD/Intel (x86_64)
        echo "Instalando PowerShell para AMD/Intel (x86_64)..."
        sudo apt-get update -y
        sudo apt-get install -y wget apt-transport-https software-properties-common
        wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update -y
        sudo apt-get install -y powershell
    else
        echo "Arquitectura no soportada para instalación de PowerShell."
        exit 1
    fi
}

# Detectar arquitectura
architecture=$(detect_architecture)
echo "Arquitectura detectada: $architecture"

# Verificar o instalar PowerShell
check_powershell


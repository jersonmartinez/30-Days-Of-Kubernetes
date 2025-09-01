#!/bin/bash

# Script para instalar Helm en WSL con Debian
# Ejecutar con: bash scripts/install-helm.sh

echo "🚀 Instalando Helm en WSL con Debian..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
echo "🔧 Instalando dependencias..."
sudo apt install -y curl wget gnupg2 software-properties-common apt-transport-https

# Instalar Helm usando script oficial
echo "⚙️ Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar instalación
echo "✅ Verificando instalación..."
helm version

# Instalar bash completion
echo "🎯 Configurando autocompletado..."
sudo mkdir -p /etc/bash_completion.d
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null

echo "🎉 ¡Helm instalado exitosamente!"
echo "Recarga tu shell con: source ~/.bashrc"
#!/bin/bash

# Script de demostración de comandos básicos de Helm
# Ejecutar con: bash scripts/helm-demo.sh

echo "🎪 Demostración de comandos básicos de Helm"

# Ver versión
echo "📋 Versión de Helm:"
helm version --short

# Agregar repositorio
echo "📚 Agregando repositorio Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami

# Listar repositorios
echo "📋 Repositorios configurados:"
helm repo list

# Actualizar repositorios
echo "🔄 Actualizando repositorios..."
helm repo update

# Buscar charts
echo "🔍 Buscando charts de nginx:"
helm search repo nginx | head -10

# Instalar aplicación de ejemplo
echo "📦 Instalando nginx de ejemplo..."
helm install demo-nginx bitnami/nginx --set service.type=ClusterIP

# Esperar un momento
sleep 5

# Listar releases
echo "📋 Releases instalados:"
helm list

# Ver estado
echo "📊 Estado del release:"
helm status demo-nginx

# Obtener valores
echo "⚙️ Valores usados:"
helm get values demo-nginx

# Desinstalar
echo "🗑️ Desinstalando demo..."
helm uninstall demo-nginx

echo "🎉 ¡Demostración completada!"
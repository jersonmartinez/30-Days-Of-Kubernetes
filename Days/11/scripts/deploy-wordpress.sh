#!/bin/bash

# Script para desplegar WordPress completo con Helm
# Ejecutar con: bash scripts/deploy-wordpress.sh

echo "🌐 Desplegando WordPress con Helm..."

# Variables de configuración
RELEASE_NAME="my-wordpress"
NAMESPACE="wordpress"

# Crear namespace si no existe
echo "📁 Creando namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Agregar repositorio Bitnami
echo "📚 Agregando repositorio Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Instalar WordPress
echo "📦 Instalando WordPress..."
helm install $RELEASE_NAME bitnami/wordpress \
  --namespace $NAMESPACE \
  --set wordpressUsername=admin \
  --set wordpressPassword=securepassword123 \
  --set mariadb.auth.rootPassword=rootpassword123 \
  --set service.type=LoadBalancer \
  --wait

# Esperar a que esté listo
echo "⏳ Esperando que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE --timeout=300s

# Obtener información de acceso
echo "🎯 Información de acceso:"
echo "Usuario: admin"
echo "Contraseña: securepassword123"
echo ""
echo "URL del servicio:"
kubectl get svc $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo "Para acceder localmente:"
echo "kubectl port-forward svc/$RELEASE_NAME 8080:80 -n $NAMESPACE"
echo "Luego visita: http://localhost:8080"

# Mostrar estado
echo "📊 Estado del despliegue:"
helm status $RELEASE_NAME -n $NAMESPACE

echo "🎉 ¡WordPress desplegado exitosamente!"
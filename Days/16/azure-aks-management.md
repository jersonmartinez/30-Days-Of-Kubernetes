# Azure Kubernetes Service (AKS) - Gestión y Despliegues

<div align="center">

[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=azure&logoColor=white)](https://azure.microsoft.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Azure CLI](https://img.shields.io/badge/Azure_CLI-0078D4?style=for-the-badge&logo=azure&logoColor=white)](https://docs.microsoft.com/en-us/cli/azure/)

**Gestión completa de AKS con Azure CLI** 🚀
*Despliegues en la nube de Microsoft*

</div>

---

> ⚠️ **Importante sobre costos**: AKS tiene un control plane gratuito durante los primeros 12 meses, pero los nodos worker siempre generan costos. Un cluster básico puede costar $2-4/día. Revisa la sección de costos antes de comenzar.

---

## 🎯 Introducción

Azure Kubernetes Service (AKS) es el servicio gestionado de Kubernetes de Microsoft Azure. En este día aprenderás a instalar y gestionar clusters AKS usando Azure CLI, incluyendo creación, escalado, actualizaciones y despliegues de aplicaciones.

### 🌟 ¿Por qué AKS?

- ✅ **Gestionado**: Microsoft maneja masters y actualizaciones
- ✅ **Integración**: Nativo con Azure services (ACR, Key Vault, etc.)
- ✅ **Escalabilidad**: Auto-scaling de nodos y pods
- ✅ **Seguridad**: Azure Active Directory y RBAC integrado
- ✅ **Costo-efectivo**: Paga solo por nodos worker

---

## 🛠️ Prerrequisitos

### 📋 Requisitos
- Cuenta de Azure con suscripción activa
- Azure CLI instalado
- kubectl instalado
- Helm (opcional para charts avanzados)
- **Resource providers registrados**: Microsoft.ContainerService, Microsoft.Network, Microsoft.Storage, Microsoft.Compute, Microsoft.OperationalInsights, Microsoft.Insights

### 💰 Costos y Free Tier de Azure

#### 🎁 **Azure Free Tier (Primeros 12 meses)**
- 💰 **$200 de crédito** para usar en 30 días
- 🖥️ **750 horas** de máquinas virtuales B1s (suficiente para nodos pequeños)
- 💾 **5GB de almacenamiento** gratuito
- ⚙️ **AKS gratuito** durante los primeros 12 meses (solo paga por nodos worker)

#### 💸 **¿Qué genera costos en AKS?**

| 🔧 Servicio | 💵 Costo Estimado | 🎯 Free Tier | ⚠️ Notas |
|-------------|-------------------|--------------|----------|
| **🖥️ Nodos Worker** | $0.008-0.20/hora | ❌ No incluido | Siempre cuesta (B1s más económico) |
| **🌐 Load Balancer** | $0.025/hora (~$18/mes) | ❌ No incluido | Solo si usas servicios LoadBalancer |
| **💾 Storage (Disks)** | $0.0005/GB/hora | ❌ No incluido | Para Persistent Volumes |
| **📤 Network Egress** | $0.087/GB | ❌ No incluido | Tráfico saliente fuera de Azure |
| **📊 Azure Monitor** | $0.50/GB logs | ❌ No incluido | Si habilitas monitoring avanzado |
| **🎛️ Control Plane** | $0.10/hora | ✅ Gratuito 12 meses | Gestionado por Microsoft |

#### � **Costos Comunes que pueden sorprenderte**

| 🚨 Problema | 💵 Costo Típico | 🔍 Cómo Detectarlo | 🛠️ Solución |
|-------------|------------------|-------------------|-------------|
| **Load Balancers olvidados** | $18/mes cada uno | `az network lb list` | Eliminar con `kubectl delete svc` |
| **Nodos sin auto-scaling** | $2-10/día extra | `kubectl get nodes` | Configurar `--enable-cluster-autoscaler` |
| **Storage no liberado** | $0.10/GB/mes | `az disk list` | Eliminar PVs antes del cluster |
| **Monitoring habilitado** | $5-20/mes | Azure Portal → Cost Analysis | Usar `--enable-addons monitoring=false` |

#### 💡 **Estrategias para minimizar costos durante pruebas**

```bash
# 🆓 Usar la VM más pequeña posible (dentro de free tier)
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 1 \
  --node-vm-size Standard_B2s \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 2

# 🔄 Evitar LoadBalancer para pruebas (usar ClusterIP)
kubectl expose deployment nginx --port=80 --type=ClusterIP

# 🌐 Para acceso externo temporal, usar port-forwarding
kubectl port-forward svc/my-service 8080:80

# 💰 Monitorear costos en tiempo real
az consumption usage list --query "[].{Name:instanceName, Cost:pretaxCost}" --output table
```

#### 📊 **Ejemplo de costo diario típico para pruebas**

| ⚙️ Configuración | 💵 Costo Diario | 🎯 Recomendado para |
|------------------|-----------------|---------------------|
| **1 nodo B2s básico** | $1-2/día | ✅ Pruebas simples |
| **2 nodos B2s + LB** | $2-4/día | ⚠️ Pruebas con servicios |
| **Auto-scaling 1-3 nodos** | $2-6/día | ⚠️ Pruebas de escalado |
| **Con monitoring completo** | $3-8/día | ❌ Producción ligera |

**💡 Tip**: Para pruebas puramente educativas, considera usar Minikube o Kind en tu máquina local en lugar de AKS, ya que son completamente gratuitos.

---

## 🚀 Instalación y Configuración

### 1. Instalar Azure CLI

#### En Windows/WSL:
```bash
# Descargar e instalar
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verificar instalación
az --version
```

#### En macOS:
```bash
brew install azure-cli
```

#### En Linux:
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Autenticación

```bash
# Iniciar sesión interactivo
az login

# O con service principal (para CI/CD)
az login --service-principal -u <app-id> -p <password> --tenant <tenant-id>
```

### 3. Configurar suscripción por defecto

```bash
# Listar suscripciones
az account list --output table

# Establecer suscripción
az account set --subscription "Your Subscription Name"
```

### 4. Registrar Resource Providers (Importante)

Antes de crear un cluster AKS, asegúrate de que los siguientes resource providers estén registrados en tu suscripción:

```bash
# Verificar estado de providers
az provider list --query "[?namespace=='Microsoft.ContainerService' || namespace=='Microsoft.Network' || namespace=='Microsoft.Storage' || namespace=='Microsoft.Compute' || namespace=='Microsoft.OperationalInsights' || namespace=='Microsoft.Insights']" --output table

# Registrar providers necesarios
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Insights

# Esperar a que se registren (puede tomar unos minutos)
az provider show --namespace Microsoft.ContainerService --query "registrationState"
```

**Nota**: Si usas `--enable-addons monitoring` al crear el cluster, necesitarás específicamente `Microsoft.OperationalInsights` y `Microsoft.Insights` registrados.

---

## 📦 Creación de Cluster AKS

### Crear Cluster Básico

```bash
# Variables
RESOURCE_GROUP="my-aks-rg"
CLUSTER_NAME="my-aks-cluster"
LOCATION="eastus"

# Crear grupo de recursos
az group create --name $RESOURCE_GROUP --location $LOCATION

# Crear cluster AKS
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --node-vm-size Standard_DS2_v2
```

**Nota**: Asegúrate de que `Microsoft.OperationalInsights` y `Microsoft.Insights` estén registrados antes de usar `--enable-addons monitoring`.

### Opciones Avanzadas

```bash
# Cluster con auto-scaling
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 1 \
  --min-count 1 \
  --max-count 5 \
  --enable-cluster-autoscaler \
  --network-plugin azure \
  --enable-managed-identity \
  --enable-addons monitoring \
  --generate-ssh-keys
```

**Nota**: El addon de monitoring requiere que `Microsoft.OperationalInsights` esté registrado.

### Conectar kubectl al Cluster

```bash
# Obtener credenciales
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Verificar conexión
kubectl get nodes
kubectl cluster-info
```

---

## 📊 Gestión del Cluster

### Escalado de Nodos

```bash
# Escalar manualmente
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3

# Habilitar auto-scaling
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 10
```

### Actualización de Kubernetes

```bash
# Ver versiones disponibles
az aks get-upgrades \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --output table

# Actualizar cluster
az aks upgrade \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.28.0
```

### Monitoreo Básico

```bash
# Ver estado del cluster
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --output table

# Ver logs de nodos
az monitor diagnostic-settings list \
  --resource /subscriptions/<subscription-id>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME
```

---

## 🚀 Despliegues en AKS

### Desplegar Aplicación Simple

```bash
# Crear namespace
kubectl create namespace demo

# Desplegar nginx
kubectl run nginx --image=nginx --namespace demo

# Exponer servicio
kubectl expose deployment nginx --port=80 --type=LoadBalancer --namespace demo

# Ver servicios
kubectl get svc --namespace demo
```

**⚠️ Nota sobre costos**: Los servicios LoadBalancer generan costos (~$18/mes). Para pruebas, considera usar `type: ClusterIP` y port-forwarding en su lugar.

### Despliegue con YAML

Crear `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-aks
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-aks
  template:
    metadata:
      labels:
        app: hello-aks
    spec:
      containers:
      - name: hello-aks
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello-aks-svc
  namespace: demo
spec:
  selector:
    app: hello-aks
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

Aplicar:

```bash
kubectl apply -f deployment.yaml
```

**💡 Para evitar costos**: Cambia `type: LoadBalancer` a `type: ClusterIP` en el YAML y usa `kubectl port-forward` para acceso temporal.

### Despliegue con Helm

```bash
# Agregar repositorio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Instalar WordPress
helm install my-wordpress bitnami/wordpress \
  --namespace demo \
  --create-namespace \
  --set service.type=LoadBalancer
```

**⚠️ Costo**: Este comando crea un LoadBalancer. Para evitar costos, cambia a `service.type=ClusterIP`.

---

## 🔧 Troubleshooting Común

### ❌ Error: "The client does not have authorization"

```bash
# Verificar permisos
az role assignment list --assignee <user-id> --output table

# Otorgar permisos si es necesario
az role assignment create \
  --assignee <user-id> \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope /subscriptions/<subscription-id>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME
```

### ❌ Error: "Resource quota exceeded"

```bash
# Ver cuotas
az vm list-usage --location $LOCATION --output table

# Solicitar aumento de cuota en Azure Portal
```

### ❌ Error: "The resource provider is not registered"

```bash
# Verificar estado de providers
az provider list --query "[?registrationState!='Registered']" --output table

# Registrar provider faltante
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationalInsights

# Esperar registro completo
az provider show --namespace Microsoft.ContainerService --query "registrationState"
```

### ❌ Error: "Monitoring addon failed to install"

```bash
# Asegurar que OperationalInsights esté registrado
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.Insights

# Reintentar creación sin monitoring inicialmente
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --generate-ssh-keys

# Luego habilitar monitoring
az aks enable-addons \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --addons monitoring
```

### ❌ Pods en estado Pending

```bash
# Ver eventos
kubectl get events --namespace demo

# Describir pod
kubectl describe pod <pod-name> --namespace demo
```

### ❌ No se puede conectar a LoadBalancer

```bash
# Ver estado del servicio
kubectl get svc --namespace demo

# Para AKS, puede tomar tiempo asignar IP externa
kubectl get svc --watch --namespace demo
```

### ❌ Costos inesperados altos

```bash
# Ver recursos que generan costo
az consumption usage list \
  --query "[?pretaxCost>0].{Name:instanceName, Cost:pretaxCost, Type:consumedService}" \
  --output table

# Ver Load Balancers activos
az network lb list --query "[].{Name:name, State:provisioningState}" --output table

# Ver discos no utilizados
az disk list --query "[?diskState=='Unattached'].{Name:name, Size:diskSizeGb}" --output table
```

### ❌ No puedo eliminar recursos

```bash
# Forzar eliminación si hay dependencias
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait

# Verificar estado de eliminación
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "provisioningState"
```

---

## 📈 Mejores Prácticas DevOps

### 🔒 **Security**
- Usar Azure AD para autenticación
- Habilitar Azure Policy para compliance
- Configurar network policies
- Usar Azure Key Vault para secrets

### 🚀 **CI/CD Integration**
```yaml
# Ejemplo GitHub Actions
- name: Deploy to AKS
  run: |
    az aks get-credentials --resource-group ${{ env.RESOURCE_GROUP }} --name ${{ env.CLUSTER_NAME }}
    kubectl apply -f k8s/
    kubectl rollout status deployment/my-app
```

### 📊 **Monitoring**
- Azure Monitor para métricas
- Azure Log Analytics para logs
- Prometheus + Grafana para monitoreo avanzado

### 💰 **Cost Optimization**
- Usar spot instances para workloads no críticos
- Auto-scaling basado en métricas
- Reserved instances para producción
- Configurar budgets y alertas de costo
- Usar node pools con diferentes tipos de VM según carga
- Eliminar recursos inmediatamente después de pruebas

---

## 🧹 Limpieza y Control de Costos

### Eliminar Cluster Completamente

```bash
# Eliminar cluster (esto elimina nodos y control plane)
az aks delete \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --yes

# Verificar que no queden recursos huérfanos
az resource list --resource-group $RESOURCE_GROUP --output table

# Eliminar grupo de recursos completo (elimina TODO)
az group delete \
  --name $RESOURCE_GROUP \
  --yes
```

### Verificar Costos Pendientes

```bash
# Ver uso actual
az consumption usage list \
  --query "[].{Resource:instanceName, Cost:pretaxCost}" \
  --output table

# Ver recursos que pueden estar generando costo
az resource list \
  --query "[?type=='Microsoft.Network/loadBalancers' || type=='Microsoft.Compute/disks' || type=='Microsoft.Storage/storageAccounts']" \
  --output table
```

### 🛑 Recursos Comunes que Olvidamos Eliminar

1. **Load Balancers**: Pueden quedar huérfanos si eliminas el cluster antes que los servicios
2. **Persistent Volumes**: Los discos EBS siguen costando aunque el cluster se elimine
3. **Public IPs**: IPs públicas asignadas a Load Balancers
4. **Storage Accounts**: Creados automáticamente para logging

### 💡 Checklist de Limpieza

- [ ] Eliminar todos los deployments y services con `kubectl delete`
- [ ] Verificar que no queden Load Balancers con `az network lb list`
- [ ] Eliminar cluster con `az aks delete`
- [ ] Verificar grupo de recursos vacío con `az resource list`
- [ ] Eliminar grupo de recursos con `az group delete`
- [ ] Revisar costos en Azure Portal para confirmar eliminación

**⚠️ Importante**: Los costos se acumulan por hora, así que elimina recursos inmediatamente después de terminar las pruebas.

---

## 🗑️ **Limpieza Completa de Recursos AKS**

### 📋 **Checklist de Limpieza**

Antes de eliminar recursos, verifica que no haya dependencias:

```bash
# Verificar recursos existentes
echo "=== Clusters ==="
az aks list --resource-group $RESOURCE_GROUP --output table

echo "=== Load Balancers ==="
az network lb list --resource-group $RESOURCE_GROUP --output table

echo "=== Public IPs ==="
az network public-ip list --resource-group $RESOURCE_GROUP --output table

echo "=== Disks ==="
az disk list --resource-group $RESOURCE_GROUP --output table

echo "=== Storage Accounts ==="
az storage account list --resource-group $RESOURCE_GROUP --output table

echo "=== Key Vaults ==="
az keyvault list --resource-group $RESOURCE_GROUP --output table
```

### 🗂️ **Eliminar Recursos por Categoría**

#### 1. **Eliminar Aplicaciones y Servicios**
```bash
# Variables
NAMESPACE="demo"

# Eliminar servicios LoadBalancer (¡importante para evitar costos!)
kubectl delete svc --all --namespace $NAMESPACE

# Eliminar deployments y pods
kubectl delete deployment --all --namespace $NAMESPACE
kubectl delete pod --all --namespace $NAMESPACE

# Eliminar configmaps, secrets y PVCs
kubectl delete configmap,secret,pvc --all --namespace $NAMESPACE

# Eliminar namespace completo
kubectl delete namespace $NAMESPACE

# Verificar que todo esté limpio
kubectl get all --namespace $NAMESPACE
```

#### 2. **Eliminar Cluster AKS**
```bash
# Opción 1: Eliminar cluster completo (elimina todo)
az aks delete \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --yes

# Opción 2: Eliminar solo node pools (mantener control plane)
az aks nodepool delete \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name nodepool1 \
  --yes

# Ver estado de eliminación
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --query provisioningState
```

#### 3. **Eliminar Recursos de Red**
```bash
# Eliminar Load Balancers huérfanos
for lb in $(az network lb list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando Load Balancer: $lb"
  az network lb delete --resource-group $RESOURCE_GROUP --name $lb
done

# Eliminar Public IPs no utilizadas
for ip in $(az network public-ip list --resource-group $RESOURCE_GROUP --query "[?ipConfiguration==null].name" -o tsv); do
  echo "Eliminando Public IP: $ip"
  az network public-ip delete --resource-group $RESOURCE_GROUP --name $ip
done

# Eliminar Network Security Groups
for nsg in $(az network nsg list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando NSG: $nsg"
  az network nsg delete --resource-group $RESOURCE_GROUP --name $nsg
done
```

#### 4. **Eliminar Almacenamiento**
```bash
# Eliminar Managed Disks no utilizados
for disk in $(az disk list --resource-group $RESOURCE_GROUP --query "[?diskState=='Unattached'].name" -o tsv); do
  echo "Eliminando disco: $disk"
  az disk delete --resource-group $RESOURCE_GROUP --name $disk --yes
done

# Eliminar Storage Accounts (¡cuidado!)
for storage in $(az storage account list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando Storage Account: $storage"
  az storage account delete --resource-group $RESOURCE_GROUP --name $storage --yes
done

# Eliminar Snapshots
for snapshot in $(az snapshot list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando snapshot: $snapshot"
  az snapshot delete --resource-group $RESOURCE_GROUP --name $snapshot --yes
done
```

#### 5. **Eliminar Recursos de Seguridad**
```bash
# Eliminar Key Vaults
for kv in $(az keyvault list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando Key Vault: $kv"
  az keyvault delete --resource-group $RESOURCE_GROUP --name $kv
done

# Eliminar Managed Identities
for identity in $(az identity list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv); do
  echo "Eliminando Managed Identity: $identity"
  az identity delete --resource-group $RESOURCE_GROUP --name $identity
done
```

#### 6. **Eliminar Grupo de Recursos Completo**
```bash
# ⚠️ ATENCIÓN: Esto elimina TODO el grupo de recursos
# Solo usar si estás seguro de que no hay recursos importantes

# Ver todos los recursos antes de eliminar
az resource list --resource-group $RESOURCE_GROUP --output table

# Eliminar grupo de recursos completo
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

# Verificar eliminación
az group show --name $RESOURCE_GROUP --query properties.provisioningState
```

### 🧹 **Script de Limpieza Automatizada**

Crear `cleanup-aks.sh`:

```bash
#!/bin/bash

# Script de limpieza completa de AKS
# Uso: ./cleanup-aks.sh <resource-group> <cluster-name>

set -e

RESOURCE_GROUP=$1
CLUSTER_NAME=$2

echo "🧹 Iniciando limpieza completa de AKS..."

# Función para esperar eliminación
wait_for_deletion() {
    local resource_type=$1
    local command=$2
    local max_attempts=30
    local attempt=1

    echo "⏳ Esperando eliminación de $resource_type..."
    while [ $attempt -le $max_attempts ]; do
        if ! eval "$command" > /dev/null 2>&1; then
            echo "✅ $resource_type eliminado exitosamente"
            return 0
        fi
        echo "   Intento $attempt/$max_attempts..."
        sleep 10
        ((attempt++))
    done

    echo "❌ Timeout esperando eliminación de $resource_type"
    return 1
}

# 1. Eliminar aplicaciones
echo "📦 Eliminando aplicaciones..."
kubectl delete namespace demo --ignore-not-found=true || true

# 2. Eliminar cluster
echo "🏗️ Eliminando cluster..."
az aks delete \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --yes || true

wait_for_deletion "cluster" "az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"

# 3. Limpiar recursos de red
echo "🌐 Limpiando recursos de red..."
az network lb delete --resource-group $RESOURCE_GROUP --name $(az network lb list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv) --yes 2>/dev/null || true
az network public-ip delete --resource-group $RESOURCE_GROUP --name $(az network public-ip list --resource-group $RESOURCE_GROUP --query "[?ipConfiguration==null].name" -o tsv) --yes 2>/dev/null || true

# 4. Limpiar discos
echo "💾 Limpiando discos..."
az disk delete --resource-group $RESOURCE_GROUP --name $(az disk list --resource-group $RESOURCE_GROUP --query "[?diskState=='Unattached'].name" -o tsv) --yes 2>/dev/null || true

# 5. Eliminar grupo de recursos
echo "🗂️ Eliminando grupo de recursos..."
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait || true

echo "✅ Limpieza completa finalizada!"
echo "💡 Verifica en Azure Portal que no queden cargos inesperados"
```

Hacer ejecutable y usar:

```bash
chmod +x cleanup-aks.sh
./cleanup-aks.sh my-aks-rg my-aks-cluster
```

### ⚠️ **Precauciones Importantes**

- **💰 Verifica costos**: Revisa Azure Cost Management después de la limpieza
- **🔒 Backup primero**: Haz backup de datos importantes antes de eliminar
- **⏱️ Espera confirmación**: Algunos recursos tardan en eliminarse completamente
- **📊 Monitorea**: Usa Azure Monitor para verificar eliminación
- **🔑 Recursos críticos**: No elimines recursos compartidos con otros servicios

### 📊 **Verificación Post-Limpieza**

```bash
# Verificar que no queden recursos
echo "=== Verificación Final ==="
az aks list --resource-group $RESOURCE_GROUP --output table
az network lb list --resource-group $RESOURCE_GROUP --output table
az disk list --resource-group $RESOURCE_GROUP --output table

# Ver costos actuales
echo "=== Costos Actuales ==="
# Accede a https://portal.azure.com/#blade/Microsoft_Azure_Billing/ModernBillingMenuBlade/Overview para ver detalles
```

### 💰 **Monitoreo de Costos en Azure**

```bash
# Ver costos por recurso
az consumption usage list \
  --query "[].{Name:instanceName, Cost:pretaxCost, Type:consumedService}" \
  --output table

# Ver presupuesto actual
az consumption budget list --output table

# Crear alerta de presupuesto
az monitor action-group create \
  --name budget-alert \
  --resource-group $RESOURCE_GROUP \
  --action email \
  --email admin@example.com

az consumption budget create \
  --budget-name monthly-budget \
  --amount 100 \
  --time-grain Monthly \
  --start-date 2025-01-01 \
  --end-date 2025-12-31 \
  --notifications "80%=budget-alert" "100%=budget-alert"
```

---

## 🏗️ **Infraestructura como Código con Terraform**

### 📁 **Estructura del Proyecto Terraform**

```
terraform-aks/
├── main.tf                 # Recursos principales
├── variables.tf            # Variables
├── outputs.tf             # Outputs
├── terraform.tfvars       # Valores de variables
├── provider.tf            # Proveedor Azure
└── modules/
    ├── aks/
    ├── networking/
    └── monitoring/
```

### 📝 **Archivos de Terraform**

#### `provider.tf`
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Backend para estado remoto (opcional)
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "aks.tfstate"
  }
}
```

#### `variables.tf`
```hcl
variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Nombre del cluster AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.28.0"
}

variable "node_count" {
  description = "Número inicial de nodos"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Tamaño de las VMs de los nodos"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "enable_auto_scaling" {
  description = "Habilitar auto-scaling"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "Número mínimo de nodos"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nodos"
  type        = number
  default     = 5
}

variable "enable_monitoring" {
  description = "Habilitar Azure Monitor"
  type        = bool
  default     = true
}
```

#### `main.tf`
```hcl
# Resource Group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "aks" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.240.0.0/16"]
}

# Network Security Group
resource "azurerm_network_security_group" "aks" {
  name                = "${var.cluster_name}-nsg"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = azurerm_subnet.aks.id
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  dynamic "oms_agent" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
    }
  }
}

# Log Analytics Workspace (para monitoring)
resource "azurerm_log_analytics_workspace" "aks" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.cluster_name}-workspace"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Container Registry (opcional)
resource "azurerm_container_registry" "aks" {
  name                = "${replace(var.cluster_name, "-", "")}acr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Role assignment para ACR pull
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.aks.id
  skip_service_principal_aad_check = true
}
```

#### `outputs.tf`
```hcl
output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.aks.name
}

output "cluster_name" {
  description = "Nombre del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  description = "ID del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "kube_config" {
  description = "Configuración de kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "client_key" {
  description = "Client key para kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate para kubectl"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Endpoint del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "acr_login_server" {
  description = "Login server del ACR"
  value       = azurerm_container_registry.aks.login_server
}

output "acr_admin_username" {
  description = "Username del ACR"
  value       = azurerm_container_registry.aks.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Password del ACR"
  value       = azurerm_container_registry.aks.admin_password
  sensitive   = true
}
```

#### `terraform.tfvars`
```hcl
resource_group_name = "my-aks-rg"
location           = "East US"
cluster_name       = "my-aks-cluster"
kubernetes_version = "1.28.0"
node_count         = 2
vm_size            = "Standard_DS2_v2"
enable_auto_scaling = true
min_node_count     = 1
max_node_count     = 5
enable_monitoring  = true
```

### 🚀 **Uso de Terraform**

#### Inicializar y Planificar
```bash
# Inicializar Terraform
terraform init

# Ver plan de cambios
terraform plan

# Aplicar cambios
terraform apply
```

#### Conectar kubectl
```bash
# Obtener credenciales del cluster creado con Terraform
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw cluster_name)

# Verificar conexión
kubectl get nodes
```

#### Destruir Infraestructura
```bash
# Destruir todo
terraform destroy

# Destruir con auto-approve
terraform destroy -auto-approve
```

### 📊 **Ventajas de Terraform para AKS**

- ✅ **Infraestructura como Código**: Versionable y reproducible
- ✅ **Estado consistente**: Evita configuración drift
- ✅ **Modular**: Reutilizable para múltiples entornos
- ✅ **Planificación**: Preview de cambios antes de aplicar
- ✅ **Paralelización**: Crea múltiples recursos en paralelo
- ✅ **Integración nativa**: Con Azure Resource Manager

---

## 🤖 **Automatización con GitHub Actions**

### 📁 **Estructura del Workflow**

```
.github/
└── workflows/
    ├── deploy-aks.yml       # Despliegue completo
    ├── cleanup-aks.yml      # Limpieza automática
    └── validate-aks.yml     # Validación de configuración
```

### 📝 **Workflow de Despliegue (`deploy-aks.yml`)**

```yaml
name: Deploy to AKS

on:
  push:
    branches: [ main ]
    paths:
      - 'k8s/**'
      - 'terraform-aks/**'
  pull_request:
    branches: [ main ]

env:
  RESOURCE_GROUP: ${{ secrets.AZURE_RESOURCE_GROUP }}
  CLUSTER_NAME: my-aks-cluster
  CONTAINER_REGISTRY: ${{ secrets.AZURE_CONTAINER_REGISTRY }}

jobs:
  terraform:
    name: 'Terraform Plan/Apply'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform-aks

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Terraform Init
      run: terraform init

    - name: Terraform Format
      run: terraform fmt -check

    - name: Terraform Validate
      run: terraform validate

    - name: Terraform Plan
      id: plan
      run: terraform plan -out=tfplan
      continue-on-error: true

    - name: Update Pull Request
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format and Validate 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          <details><summary>Show Plan</summary>

          \`\`\`\n
          ${process.env.PLAN}
          \`\`\`

          </details>

          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: Terraform Plan Status
      if: steps.plan.outcome == 'failure'
      run: exit 1

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve tfplan

  build:
    name: 'Build and Push Container'
    runs-on: ubuntu-latest
    needs: terraform
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Build and push image
      uses: azure/docker-login@v1
      with:
        login-server: ${{ env.CONTAINER_REGISTRY }}.azurecr.io
        username: ${{ secrets.ACR_USERNAME }}
        password: ${{ secrets.ACR_PASSWORD }}

    - name: Build and Push
      run: |
        docker build . -t ${{ env.CONTAINER_REGISTRY }}.azurecr.io/my-app:${{ github.sha }}
        docker push ${{ env.CONTAINER_REGISTRY }}.azurecr.io/my-app:${{ github.sha }}

  deploy:
    name: 'Deploy to AKS'
    runs-on: ubuntu-latest
    needs: [terraform, build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Get AKS credentials
      run: |
        az aks get-credentials \
          --resource-group $RESOURCE_GROUP \
          --name $CLUSTER_NAME

    - name: Deploy to AKS
      run: |
        # Update image in deployment
        sed -i 's|image:.*|image: ${{ env.CONTAINER_REGISTRY }}.azurecr.io/my-app:${{ github.sha }}|g' k8s/deployment.yaml
        
        kubectl apply -f k8s/
        kubectl rollout status deployment/my-app

    - name: Verify deployment
      run: |
        kubectl get pods
        kubectl get services

  cleanup:
    name: 'Cleanup Old Resources'
    runs-on: ubuntu-latest
    needs: deploy
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Get AKS credentials
      run: |
        az aks get-credentials \
          --resource-group $RESOURCE_GROUP \
          --name $CLUSTER_NAME

    - name: Cleanup old resources
      run: |
        # Eliminar pods completados
        kubectl delete pods --field-selector=status.phase=Succeeded

        # Eliminar jobs completados
        kubectl delete jobs --field-selector=status.successful=1

        # Limpiar imágenes no utilizadas (opcional)
        echo "Limpieza completada"
```

### 📝 **Workflow de Limpieza (`cleanup-aks.yml`)**

```yaml
name: Cleanup AKS Resources

on:
  schedule:
    # Ejecutar todos los domingos a las 2 AM UTC
    - cron: '0 2 * * 0'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to cleanup'
        required: true
        default: 'dev'
        type: choice
        options:
        - dev
        - staging
        - prod

env:
  RESOURCE_GROUP: ${{ secrets.AZURE_RESOURCE_GROUP }}
  CLUSTER_NAME: my-aks-cluster

jobs:
  cleanup:
    name: 'Cleanup AKS Resources'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Get AKS credentials
      run: |
        az aks get-credentials \
          --resource-group $RESOURCE_GROUP \
          --name $CLUSTER_NAME

    - name: Cleanup Kubernetes resources
      run: |
        # Eliminar pods en estado Error o CrashLoopBackOff
        kubectl delete pods --field-selector=status.phase=Failed
        kubectl delete pods --field-selector=status.phase=Pending --force

        # Eliminar jobs completados hace más de 1 hora
        kubectl delete jobs --field-selector=status.successful=1 --older-than=1h

        # Limpiar PVC no utilizados
        kubectl delete pvc --field-selector=status.phase=Lost

        # Limpiar configmaps huérfanos
        kubectl delete configmap --all --namespace=default

    - name: Cleanup Azure resources
      run: |
        # Eliminar discos no utilizados
        for disk in $(az disk list --resource-group $RESOURCE_GROUP --query "[?diskState=='Unattached'].name" -o tsv); do
          echo "Eliminando disco: $disk"
          az disk delete --resource-group $RESOURCE_GROUP --name $disk --yes
        done

        # Eliminar snapshots antiguos
        for snapshot in $(az snapshot list --resource-group $RESOURCE_GROUP --query "[?timeCreated<'$(date -d '7 days ago' +%Y-%m-%dT%H:%MZ)'].name" -o tsv); do
          echo "Eliminando snapshot: $snapshot"
          az snapshot delete --resource-group $RESOURCE_GROUP --name $snapshot --yes
        done

    - name: Send notification
      if: always()
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        text: "AKS Cleanup completed - ${{ job.status }}"
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 🔐 **Configuración de Secrets en GitHub**

Ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `AZURE_CREDENTIALS` | Service Principal credentials | `az ad sp create-for-rbac --name "GitHubActions" --role contributor --scopes /subscriptions/<subscription-id> --sdk-auth` |
| `AZURE_RESOURCE_GROUP` | Resource Group name | Nombre del RG |
| `AZURE_CONTAINER_REGISTRY` | ACR name | Nombre del registry |
| `ACR_USERNAME` | ACR admin username | Desde Azure Portal |
| `ACR_PASSWORD` | ACR admin password | Desde Azure Portal |
| `SLACK_WEBHOOK_URL` | Slack webhook (opcional) | Crear en Slack App |

### 📊 **Beneficios de GitHub Actions para AKS**

- ✅ **CI/CD completo**: Desde código hasta producción
- ✅ **Automatización**: Despliegues y limpiezas programadas
- ✅ **Seguridad**: Secrets encriptados
- ✅ **Monitoreo**: Logs detallados de cada paso
- ✅ **Integración**: Con issues, PRs y notificaciones
- ✅ **Reutilización**: Workflows modulares y compartibles

---

## 🎯 Próximos Pasos

- **Día 17**: Google Kubernetes Engine (GKE)
- **Día 18**: Comparativa Cloud vs On-premise
- **Proyecto**: Multi-cloud deployment

### 📚 Recursos Adicionales

- [Documentación AKS](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/aks)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)

---

<div align="center">

### 💡 **Recuerda**: AKS simplifica la gestión de Kubernetes en Azure

**¿Listo para explorar otras nubes?** → [Día 17](../17/)

</div>
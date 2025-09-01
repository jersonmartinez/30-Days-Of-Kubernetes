# Google Kubernetes Engine (GKE) - Gestión y Despliegues

<div align="center">

[![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Google Cloud SDK](https://img.shields.io/badge/Google_Cloud_SDK-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/sdk)

**Gestión completa de GKE con Google Cloud SDK** 🚀
*Despliegues en la nube de Google*

</div>

---

## 🎯 Introducción

Google Kubernetes Engine (GKE) es el servicio gestionado de Kubernetes de Google Cloud Platform. En este día aprenderás a instalar y gestionar clusters GKE usando Google Cloud SDK (gcloud), incluyendo creación, escalado, actualizaciones y despliegues de aplicaciones.

### 🌟 ¿Por qué GKE?

- ✅ **Gestionado**: Google maneja masters y actualizaciones
- ✅ **Integración**: Nativo con GCP services (GCR, IAM, VPC, etc.)
- ✅ **Autopilot**: Modo sin servidor opcional
- ✅ **Seguridad**: Workload Identity y Binary Authorization
- ✅ **Performance**: Optimizado para workloads de Google

---

## 🛠️ Prerrequisitos

### 📋 Requisitos
- Cuenta de Google Cloud con proyecto activo
- Google Cloud SDK (gcloud) instalado
- kubectl instalado
- Helm (opcional para charts avanzados)

### 💰 Costos Estimados
- Control plane: $0.10/hora (gratuito en Autopilot)
- Nodos: Según tipo de instancia GCE
- Storage: $0.10/GB/mes
- Networking: Según uso

---

## 💰 💸 **Análisis Detallado de Costos GKE**

### 📊 **Tabla de Costos por Servicio**

| Servicio | Costo Mensual | Free Tier Disponible | 💡 Recomendación |
|----------|---------------|---------------------|------------------|
| **Control Plane** | $73/mes | ✅ **Gratuito en Autopilot** | Usa Autopilot para ahorrar |
| **Nodos (e2-micro)** | $4.30/mes | ❌ No aplica | Solo para testing básico |
| **Nodos (e2-medium)** | $25.46/mes | ❌ No aplica | Buena opción para desarrollo |
| **Storage (SSD)** | $0.17/GB/mes | ✅ **5GB gratis** | Monitorea uso continuo |
| **Load Balancer** | $18.26/mes | ❌ No aplica | ⚠️ **Costo sorpresa común** |
| **Cloud Monitoring** | $0.2586/GB | ✅ **50GB gratis/mes** | Incluye métricas básicas |
| **Cloud Logging** | $0.50/GB | ✅ **5GB gratis/mes** | Suficiente para debugging |

### 🎁 **Free Tier de Google Cloud para GKE**

| Recurso | Límite Gratuito | 💡 Para qué sirve |
|---------|----------------|-------------------|
| **Compute Engine** | $300 crédito inicial | Crear instancias para nodos |
| **Kubernetes Engine** | Gratuito con Autopilot | Control plane sin costo |
| **Cloud Storage** | 5GB gratis | Almacenar backups y configs |
| **Cloud Monitoring** | 50GB gratis | Métricas básicas del cluster |
| **Cloud Logging** | 5GB gratis | Logs de aplicaciones |

### ⚠️ **Sorpresas de Costos Comunes**

| Problema | Cómo Detectarlo | 💰 Costo Típico | 🔧 Solución |
|----------|----------------|------------------|-------------|
| **LoadBalancers huérfanos** | `kubectl get svc --all-namespaces` | $18/mes cada uno | Eliminar servicios no usados |
| **Storage no reclamado** | `gcloud compute disks list` | $0.17/GB/mes | Borrar discos huérfanos |
| **Monitoring excesivo** | Cloud Billing → Usage | $0.26/GB extra | Configurar retención de logs |
| **Nodos sobreprovisionados** | `kubectl get nodes` | $25+/mes por nodo | Usar cluster autoscaling |
| **Snapshots olvidados** | `gcloud compute snapshots list` | $0.026/GB/mes | Política de retención automática |

### 🚀 **Estrategias de Optimización de Costos**

#### 💡 **Optimizaciones Inmediatas**
```bash
# Usar Autopilot (gratuito control plane)
gcloud container clusters create-auto my-cluster \
  --project my-project \
  --region us-central1

# Configurar autoscaling agresivo
gcloud container clusters update my-cluster \
  --enable-autoscaling \
  --min-nodes 0 \
  --max-nodes 3 \
  --region us-central1

# Usar preemptible nodes para dev/test
gcloud container node-pools create preemptible-pool \
  --cluster my-cluster \
  --node-count 1 \
  --machine-type e2-medium \
  --preemptible \
  --region us-central1
```

#### 📊 **Monitoreo de Costos**
```bash
# Ver costos por servicio
gcloud billing accounts list
gcloud billing projects link my-project --billing-account=XXXXXX-XXXXXX-XXXXXX

# Alertas de presupuesto
gcloud billing budgets create my-budget \
  --billing-account=XXXXXX-XXXXXX-XXXXXX \
  --amount=100 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90
```

#### 🎯 **Recomendaciones por Caso de Uso**

| Caso de Uso | 💰 Costo Mensual Estimado | ⚡ Setup Óptimo |
|-------------|---------------------------|-----------------|
| **Aprendizaje/PoC** | $0-10/mes | Autopilot + Free Tier |
| **Desarrollo** | $25-50/mes | e2-medium + autoscaling |
| **Producción Pequeña** | $100-300/mes | N1-standard + monitoring |
| **Producción Grande** | $500+/mes | Optimizado + committed use |

### 💡 **Tips para Mantener Costos Bajos**

- 🔄 **Usa Autopilot**: Control plane gratuito
- 📏 **Cluster pequeño**: Comienza con 1-2 nodos
- ⏰ **Preemptible VMs**: 80% descuento para workloads tolerantes
- 📊 **Monitorea siempre**: Configura alertas de presupuesto
- 🧹 **Limpia regularmente**: Elimina recursos no usados
- 📈 **Committed use**: Descuentos por uso garantizado (1-3 años)

> 💰 **Recuerda**: Los costos pueden escalar rápidamente. Monitorea tu uso en Cloud Billing y configura alertas tempranas.

---

## 🚀 Instalación y Configuración

### 1. Instalar Google Cloud SDK

#### En Windows/WSL:
```bash
# Descargar instalador
curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-400.0.0-linux-x86_64.tar.gz | tar xz

# Instalar
./google-cloud-sdk/install.sh

# Inicializar
./google-cloud-sdk/bin/gcloud init

# Agregar al PATH
echo 'export PATH=$PATH:~/google-cloud-sdk/bin' >> ~/.bashrc
source ~/.bashrc
```

#### En macOS:
```bash
brew install --cask google-cloud-sdk
gcloud init
```

#### En Linux:
```bash
# Ubuntu/Debian
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt update && sudo apt install google-cloud-sdk
gcloud init
```

### 2. Autenticación

```bash
# Iniciar sesión
gcloud auth login

# O con service account (para CI/CD)
gcloud auth activate-service-account --key-file=key.json

# Listar cuentas
gcloud auth list
```

### 3. Configurar Proyecto

```bash
# Listar proyectos
gcloud projects list

# Establecer proyecto
gcloud config set project my-project-id

# Ver configuración
gcloud config list
```

---

## 📦 Creación de Cluster GKE

### Crear Cluster Estándar

```bash
# Variables
PROJECT_ID="my-gcp-project"
CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"

# Crear cluster básico
gcloud container clusters create $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --num-nodes 2 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5
```

### Crear Cluster Autopilot (Recomendado)

```bash
# Cluster sin gestión de nodos
gcloud container clusters create-auto $CLUSTER_NAME \
  --project $PROJECT_ID \
  --region us-central1 \
  --enable-autopilot
```

### Opciones Avanzadas

```bash
# Cluster con configuración avanzada
gcloud container clusters create $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --num-nodes 3 \
  --machine-type n1-standard-2 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10 \
  --enable-network-policy \
  --enable-stackdriver-kubernetes \
  --enable-ip-alias \
  --enable-private-nodes \
  --master-ipv4-cidr 172.16.0.0/28
```

### Conectar kubectl al Cluster

```bash
# Obtener credenciales
gcloud container clusters get-credentials $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE

# Verificar conexión
kubectl get nodes
kubectl cluster-info
```

---

## 📊 Gestión del Cluster

### Escalado de Nodos

```bash
# Escalar cluster
gcloud container clusters resize $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --num-nodes 5

# Escalar node pool
gcloud container clusters update $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 10
```

### Actualización de Kubernetes

```bash
# Ver versiones disponibles
gcloud container get-server-config \
  --project $PROJECT_ID \
  --zone $ZONE

# Actualizar cluster
gcloud container clusters upgrade $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --cluster-version 1.28.0

# Actualizar node pools
gcloud container node-pools upgrade $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --node-pool default-pool \
  --cluster-version 1.28.0
```

### Monitoreo Básico

```bash
# Ver estado del cluster
gcloud container clusters describe $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE

# Ver operaciones
gcloud container operations list \
  --project $PROJECT_ID \
  --zone $ZONE

# Ver logs
gcloud logging read "resource.type=k8s_cluster" \
  --project $PROJECT_ID \
  --limit 10
```

---

## 🚀 Despliegues en GKE

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

### Despliegue con YAML

Crear `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-gke
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-gke
  template:
    metadata:
      labels:
        app: hello-gke
    spec:
      containers:
      - name: hello-gke
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello-gke-svc
  namespace: demo
spec:
  selector:
    app: hello-gke
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

Aplicar:

```bash
kubectl apply -f deployment.yaml
```

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

---

## 🔧 Troubleshooting Común

### ❌ Error: "Insufficient regional quota"

```bash
# Ver cuotas
gcloud compute regions describe us-central1

# Solicitar aumento de cuota
gcloud compute regions request-quota-increase us-central1 --quota cpu --value 50
```

### ❌ Error: "Permission denied"

```bash
# Verificar permisos
gcloud projects get-iam-policy $PROJECT_ID

# Otorgar roles necesarios
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member user:email@example.com \
  --role roles/container.admin
```

### ❌ Nodes no se unen al cluster

```bash
# Verificar configuración de red
kubectl get nodes
kubectl describe node <node-name>

# Ver logs de kubelet
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_name:<node-name>" \
  --project $PROJECT_ID
```

### ❌ LoadBalancer no obtiene IP

```bash
# Ver eventos del servicio
kubectl describe svc <service-name> --namespace demo

# Verificar configuración de red
gcloud compute networks list
```

---

## 📈 Mejores Prácticas DevOps

### 🔒 **Security**
- Usar Workload Identity
- Habilitar Binary Authorization
- Configurar network policies
- Usar Google Cloud Armor

### 🚀 **CI/CD Integration**
```yaml
# Ejemplo Cloud Build
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  args:
  - container
  - clusters
  - get-credentials
  - my-cluster
  - --zone=us-central1-a
  - --project=my-project
- name: 'gcr.io/cloud-builders/kubectl'
  args: ['apply', '-f', 'k8s/']
```

### 📊 **Monitoring**
- Cloud Monitoring para métricas
- Cloud Logging para logs
- Cloud Trace para tracing
- Prometheus + Grafana para monitoreo avanzado

### 💰 **Cost Optimization**
- Usar Preemptible VMs
- Autopilot para workloads variables
- Committed use discounts
- Cluster autoscaling

---

## 🧹 Limpieza

```bash
# Eliminar cluster
gcloud container clusters delete $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet

# Eliminar discos no utilizados
gcloud compute disks list --project $PROJECT_ID
gcloud compute disks delete <disk-name> --project $PROJECT_ID --zone $ZONE
```

---

## 🗑️ **Limpieza Completa de Recursos GKE**

### 📋 **Checklist de Limpieza**

Antes de eliminar recursos, verifica que no haya dependencias:

```bash
# Verificar recursos existentes
echo "=== Clusters ==="
gcloud container clusters list --project $PROJECT_ID

echo "=== Discos ==="
gcloud compute disks list --project $PROJECT_ID

echo "=== Load Balancers ==="
gcloud compute forwarding-rules list --project $PROJECT_ID

echo "=== Static IPs ==="
gcloud compute addresses list --project $PROJECT_ID

echo "=== Firewalls ==="
gcloud compute firewall-rules list --project $PROJECT_ID

echo "=== Service Accounts ==="
gcloud iam service-accounts list --project $PROJECT_ID
```

### 🗂️ **Eliminar Recursos por Categoría**

#### 1. **Eliminar Aplicaciones y Servicios**
```bash
# Variables
NAMESPACE="demo"

# Eliminar servicios LoadBalancer (¡importante para evitar costos!)
kubectl delete svc --all --namespace $NAMESPACE

# Eliminar deployments
kubectl delete deployment --all --namespace $NAMESPACE

# Eliminar configmaps y secrets
kubectl delete configmap --all --namespace $NAMESPACE
kubectl delete secret --all --namespace $NAMESPACE

# Eliminar namespace completo
kubectl delete namespace $NAMESPACE

# Verificar que todo esté limpio
kubectl get all --namespace $NAMESPACE
```

#### 2. **Eliminar Cluster GKE**
```bash
# Opción 1: Eliminar cluster completo (elimina todo)
gcloud container clusters delete $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet

# Opción 2: Eliminar solo node pools (mantener control plane)
gcloud container node-pools delete default-pool \
  --cluster $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet

# Ver estado de eliminación
gcloud container operations list \
  --project $PROJECT_ID \
  --zone $ZONE \
  --filter="operationType=DELETE_CLUSTER"
```

#### 3. **Eliminar Recursos de Red**
```bash
# Eliminar Load Balancers huérfanos
gcloud compute forwarding-rules list --project $PROJECT_ID
gcloud compute forwarding-rules delete <forwarding-rule-name> \
  --project $PROJECT_ID \
  --region us-central1 \
  --quiet

# Eliminar target pools
gcloud compute target-pools list --project $PROJECT_ID
gcloud compute target-pools delete <target-pool-name> \
  --project $PROJECT_ID \
  --region us-central1 \
  --quiet

# Eliminar backend services
gcloud compute backend-services list --project $PROJECT_ID
gcloud compute backend-services delete <backend-service-name> \
  --project $PROJECT_ID \
  --global \
  --quiet
```

#### 4. **Eliminar Almacenamiento**
```bash
# Listar todos los discos
gcloud compute disks list --project $PROJECT_ID

# Eliminar discos persistentes no utilizados
gcloud compute disks delete <disk-name> \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet

# Eliminar snapshots
gcloud compute snapshots list --project $PROJECT_ID
gcloud compute snapshots delete <snapshot-name> \
  --project $PROJECT_ID \
  --quiet
```

#### 5. **Eliminar Recursos de Red Adicionales**
```bash
# Eliminar direcciones IP estáticas
gcloud compute addresses list --project $PROJECT_ID
gcloud compute addresses delete <address-name> \
  --project $PROJECT_ID \
  --region us-central1 \
  --quiet

# Eliminar reglas de firewall creadas
gcloud compute firewall-rules list --project $PROJECT_ID
gcloud compute firewall-rules delete <firewall-rule-name> \
  --project $PROJECT_ID \
  --quiet
```

#### 6. **Eliminar Service Accounts y Claves**
```bash
# Listar service accounts
gcloud iam service-accounts list --project $PROJECT_ID

# Eliminar claves de service account
gcloud iam service-accounts keys list \
  --iam-account <service-account-email> \
  --project $PROJECT_ID

gcloud iam service-accounts keys delete <key-id> \
  --iam-account <service-account-email> \
  --project $PROJECT_ID \
  --quiet

# Eliminar service account completo (¡cuidado!)
gcloud iam service-accounts delete <service-account-email> \
  --project $PROJECT_ID \
  --quiet
```

### 🧹 **Script de Limpieza Automatizada**

Crear `cleanup-gke.sh`:

```bash
#!/bin/bash

# Script de limpieza completa de GKE
# Uso: ./cleanup-gke.sh <project-id> <cluster-name> <zone> <namespace>

set -e

PROJECT_ID=$1
CLUSTER_NAME=$2
ZONE=$3
NAMESPACE=$4

echo "🧹 Iniciando limpieza completa de GKE..."

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
kubectl delete namespace $NAMESPACE --ignore-not-found=true || true

# 2. Eliminar cluster
echo "🏗️ Eliminando cluster..."
gcloud container clusters delete $CLUSTER_NAME \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet || true

wait_for_deletion "cluster" "gcloud container clusters describe $CLUSTER_NAME --project $PROJECT_ID --zone $ZONE"

# 3. Limpiar recursos de red
echo "🌐 Limpiando recursos de red..."
gcloud compute forwarding-rules delete $(gcloud compute forwarding-rules list --project $PROJECT_ID --format="value(name)") \
  --project $PROJECT_ID \
  --region ${ZONE%-*} \
  --quiet || true

# 4. Limpiar discos
echo "💾 Limpiando discos..."
gcloud compute disks delete $(gcloud compute disks list --project $PROJECT_ID --format="value(name)") \
  --project $PROJECT_ID \
  --zone $ZONE \
  --quiet || true

echo "✅ Limpieza completa finalizada!"
echo "💡 Verifica en Cloud Billing que no queden cargos inesperados"
```

Hacer ejecutable y usar:

```bash
chmod +x cleanup-gke.sh
./cleanup-gke.sh my-project my-cluster us-central1-a demo
```

### ⚠️ **Precauciones Importantes**

- **💰 Verifica costos**: Revisa Cloud Billing después de la limpieza
- **🔒 Backup primero**: Haz backup de datos importantes antes de eliminar
- **⏱️ Espera confirmación**: Algunos recursos tardan en eliminarse completamente
- **📊 Monitorea**: Usa Cloud Monitoring para verificar eliminación
- **🔑 Service Accounts**: No elimines service accounts en uso por otros servicios

### 📊 **Verificación Post-Limpieza**

```bash
# Verificar que no queden recursos
echo "=== Verificación Final ==="
gcloud container clusters list --project $PROJECT_ID
gcloud compute disks list --project $PROJECT_ID
gcloud compute forwarding-rules list --project $PROJECT_ID
gcloud compute addresses list --project $PROJECT_ID

# Ver costos actuales
echo "=== Costos Actuales ==="
gcloud billing accounts list
# Accede a https://console.cloud.google.com/billing para ver detalles
```

---

## 🏗️ **Infraestructura como Código con Terraform**

### 📁 **Estructura del Proyecto Terraform**

```
terraform-gke/
├── main.tf                 # Recursos principales
├── variables.tf            # Variables
├── outputs.tf             # Outputs
├── terraform.tfvars       # Valores de variables
├── provider.tf            # Proveedor GCP
└── modules/
    ├── vpc/
    ├── gke/
    └── monitoring/
```

### 📝 **Archivos de Terraform**

#### `provider.tf`
```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Backend para estado remoto (opcional)
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "gke"
  }
}
```

#### `variables.tf`
```hcl
variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona de GCP"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Nombre del cluster GKE"
  type        = string
  default     = "my-gke-cluster"
}

variable "node_count" {
  description = "Número inicial de nodos"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Tipo de máquina para nodos"
  type        = string
  default     = "e2-medium"
}

variable "enable_autopilot" {
  description = "Habilitar modo Autopilot"
  type        = bool
  default     = false
}
```

#### `main.tf`
```hcl
# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.enable_autopilot ? var.region : var.zone

  # Configuración de red
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Configuración de Autopilot
  dynamic "cluster_autoscaling" {
    for_each = var.enable_autopilot ? [1] : []
    content {
      enabled = true
      resource_limits {
        resource_type = "cpu"
        minimum       = 1
        maximum       = 1000
      }
      resource_limits {
        resource_type = "memory"
        minimum       = 1
        maximum       = 1000
      }
    }
  }

  # Configuración estándar
  dynamic "node_pool" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      name       = "default-pool"
      node_count = var.node_count

      node_config {
        machine_type = var.machine_type
        oauth_scopes = [
          "https://www.googleapis.com/auth/cloud-platform"
        ]
      }

      autoscaling {
        min_node_count = 1
        max_node_count = 5
      }
    }
  }

  # Habilitar features
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# Service Account para nodos
resource "google_service_account" "gke_sa" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_binding" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}
```

#### `outputs.tf`
```hcl
output "cluster_name" {
  description = "Nombre del cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint del cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA del cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "kubectl_command" {
  description = "Comando para conectar kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
}

output "vpc_network" {
  description = "Nombre de la VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Nombre de la subred"
  value       = google_compute_subnetwork.subnet.name
}
```

#### `terraform.tfvars`
```hcl
project_id      = "my-gcp-project"
region          = "us-central1"
zone            = "us-central1-a"
cluster_name    = "my-gke-cluster"
node_count      = 2
machine_type    = "e2-medium"
enable_autopilot = false
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
terraform output kubectl_command
eval $(terraform output -raw kubectl_command)

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

### 📊 **Ventajas de Terraform para GKE**

- ✅ **Infraestructura como Código**: Versionable y reproducible
- ✅ **Estado consistente**: Evita configuración drift
- ✅ **Modular**: Reutilizable para múltiples entornos
- ✅ **Planificación**: Preview de cambios antes de aplicar
- ✅ **Paralelización**: Crea múltiples recursos en paralelo
- ✅ **Gráficos de dependencias**: Maneja dependencias automáticamente

---

## 🤖 **Automatización con GitHub Actions**

### 📁 **Estructura del Workflow**

```
.github/
└── workflows/
    ├── deploy-gke.yml       # Despliegue completo
    ├── cleanup-gke.yml      # Limpieza automática
    └── validate-gke.yml     # Validación de configuración
```

### 📝 **Workflow de Despliegue (`deploy-gke.yml`)**

```yaml
name: Deploy to GKE

on:
  push:
    branches: [ main ]
    paths:
      - 'k8s/**'
      - 'terraform/**'
  pull_request:
    branches: [ main ]

env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  CLUSTER_NAME: my-gke-cluster
  REGION: us-central1
  ZONE: us-central1-a

jobs:
  terraform:
    name: 'Terraform Plan/Apply'
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    - name: Configure GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Terraform Init
      run: terraform init

    - name: Terraform Format
      run: terraform fmt -check

    - name: Terraform Validate
      run: terraform validate

    - name: Terraform Plan
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

  deploy:
    name: 'Deploy to GKE'
    runs-on: ubuntu-latest
    needs: terraform
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials $CLUSTER_NAME \
          --zone $ZONE \
          --project $PROJECT_ID

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Deploy to GKE
      run: |
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

    - name: Configure GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials $CLUSTER_NAME \
          --zone $ZONE \
          --project $PROJECT_ID

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

    - name: Cleanup old resources
      run: |
        # Eliminar pods completados
        kubectl delete pods --field-selector=status.phase=Succeeded

        # Eliminar jobs completados
        kubectl delete jobs --field-selector=status.successful=1

        # Limpiar imágenes no utilizadas (opcional)
        echo "Limpieza completada"
```

### 📝 **Workflow de Limpieza (`cleanup-gke.yml`)**

```yaml
name: Cleanup GKE Resources

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
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  CLUSTER_NAME: my-gke-cluster
  REGION: us-central1
  ZONE: us-central1-a

jobs:
  cleanup:
    name: 'Cleanup GKE Resources'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Setup gcloud
      uses: google-github-actions/setup-gcloud@v2

    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials $CLUSTER_NAME \
          --zone $ZONE \
          --project $PROJECT_ID

    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'

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

    - name: Cleanup GCP resources
      run: |
        # Eliminar discos no utilizados
        for disk in $(gcloud compute disks list --filter="-users:*" --format="value(name)"); do
          echo "Eliminando disco: $disk"
          gcloud compute disks delete $disk --zone=$ZONE --quiet
        done

        # Eliminar snapshots antiguos
        for snapshot in $(gcloud compute snapshots list --filter="creationTimestamp<-7d" --format="value(name)"); do
          echo "Eliminando snapshot: $snapshot"
          gcloud compute snapshots delete $snapshot --quiet
        done

    - name: Send notification
      if: always()
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        text: "GKE Cleanup completed - ${{ job.status }}"
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 🔐 **Configuración de Secrets en GitHub**

Ve a **Settings > Secrets and variables > Actions** y agrega:

```
GCP_PROJECT_ID     # Tu project ID de GCP
GCP_SA_KEY         # JSON key del service account
SLACK_WEBHOOK_URL  # Para notificaciones (opcional)
```

### 📊 **Beneficios de GitHub Actions para GKE**

- ✅ **CI/CD completo**: Desde código hasta producción
- ✅ **Automatización**: Despliegues y limpiezas programadas
- ✅ **Seguridad**: Secrets encriptados
- ✅ **Monitoreo**: Logs detallados de cada paso
- ✅ **Integración**: Con issues, PRs y notificaciones
- ✅ **Reutilización**: Workflows modulares y compartibles

---

## 🎯 Próximos Pasos

- **Día 18**: Comparativa Cloud vs On-premise
- **Día 19**: Multi-cluster management
- **Proyecto**: Hybrid cloud deployment

### 📚 Recursos Adicionales

- [Documentación GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [GitHub Actions for GCP](https://github.com/google-github-actions)

---

<div align="center">

### 💡 **Recuerda**: GKE ofrece la simplicidad de Google Cloud

**¿Listo para comparar nubes?** → [Día 18](../18/)

</div>

- **Día 18**: Comparativa Cloud vs On-premise
- **Día 19**: Multi-cluster management
- **Proyecto**: Hybrid cloud deployment

### 📚 Recursos Adicionales

- [Documentación GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)

---

<div align="center">

### 💡 **Recuerda**: GKE ofrece la simplicidad de Google Cloud

**¿Listo para comparar nubes?** → [Día 18](../18/)

</div>
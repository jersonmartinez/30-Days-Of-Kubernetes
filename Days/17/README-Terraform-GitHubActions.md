# Infraestructura GKE con Terraform y GitHub Actions

Este directorio contiene la configuración completa para desplegar y gestionar un cluster GKE usando Terraform y automatización con GitHub Actions.

## 📁 Estructura del Proyecto

```
Days/17/
├── google-gke-management.md    # Documentación completa
├── terraform-gke/              # Configuración de Terraform
│   ├── main.tf                 # Recursos principales
│   ├── variables.tf            # Variables de configuración
│   ├── outputs.tf              # Outputs de Terraform
│   ├── provider.tf             # Proveedor GCP
│   └── terraform.tfvars.example # Ejemplo de variables
├── .github/
│   └── workflows/              # Workflows de GitHub Actions
│       ├── deploy-gke.yml      # Despliegue completo
│       ├── cleanup-gke.yml     # Limpieza automática
│       └── validate-gke.yml    # Validación de configuración
└── k8s/                        # Manifests de Kubernetes (crear)
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

## 🚀 Inicio Rápido

### 1. Preparar Variables de Terraform

```bash
cd terraform-gke
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

```hcl
project_id      = "tu-project-id"
region          = "us-central1"
zone            = "us-central1-a"
cluster_name    = "mi-cluster-gke"
node_count      = 2
machine_type    = "e2-medium"
enable_autopilot = false
```

### 2. Configurar Autenticación GCP

#### Opción A: Service Account Key (Recomendado para CI/CD)
```bash
# Crear service account
gcloud iam service-accounts create terraform-sa \
  --description="Service account for Terraform" \
  --display-name="Terraform SA"

# Asignar roles necesarios
gcloud projects add-iam-policy-binding tu-project-id \
  --member="serviceAccount:terraform-sa@tu-project-id.iam.gserviceaccount.com" \
  --role="roles/editor"

# Crear y descargar key
gcloud iam service-accounts keys create key.json \
  --iam-account=terraform-sa@tu-project-id.iam.gserviceaccount.com
```

#### Opción B: Autenticación de Usuario (Para desarrollo local)
```bash
gcloud auth login
gcloud config set project tu-project-id
```

### 3. Inicializar y Desplegar

```bash
# Inicializar Terraform
terraform init

# Ver plan de cambios
terraform plan

# Aplicar cambios
terraform apply
```

### 4. Conectar kubectl

```bash
# Obtener credenciales del cluster
terraform output kubectl_command
eval $(terraform output -raw kubectl_command)

# Verificar conexión
kubectl get nodes
kubectl get pods
```

## 🔧 Configuración de GitHub Actions

### Secrets Requeridos

Ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `GCP_PROJECT_ID` | ID de tu proyecto GCP | `gcloud config get-value project` |
| `GCP_SA_KEY` | JSON key del service account | Descargar desde GCP Console |
| `SLACK_WEBHOOK_URL` | Webhook de Slack (opcional) | Crear en Slack App |

### Service Account para GitHub Actions

```bash
# Crear service account específico para CI/CD
gcloud iam service-accounts create github-actions-sa \
  --description="Service account for GitHub Actions" \
  --display-name="GitHub Actions SA"

# Asignar roles mínimos necesarios
gcloud projects add-iam-policy-binding tu-project-id \
  --member="serviceAccount:github-actions-sa@tu-project-id.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding tu-project-id \
  --member="serviceAccount:github-actions-sa@tu-project-id.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding tu-project-id \
  --member="serviceAccount:github-actions-sa@tu-project-id.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

## 📋 Workflows Disponibles

### 1. `deploy-gke.yml` - Despliegue Completo
- **Trigger**: Push a `main` o cambios en `k8s/` o `terraform/`
- **Jobs**:
  - `terraform`: Plan y apply de infraestructura
  - `deploy`: Despliegue de aplicaciones Kubernetes
  - `cleanup`: Limpieza de recursos antiguos

### 2. `cleanup-gke.yml` - Limpieza Automática
- **Trigger**: Programado (domingos 2 AM) o manual
- **Funciones**:
  - Eliminar pods fallidos
  - Limpiar jobs completados
  - Eliminar discos huérfanos
  - Notificaciones por Slack

### 3. `validate-gke.yml` - Validación
- **Trigger**: Push o PR a ramas principales
- **Validaciones**:
  - Sintaxis de manifests Kubernetes
  - Configuración de Terraform
  - Escaneo de seguridad con Trivy
  - Linting de código

## 🏗️ Personalización

### Variables de Terraform

| Variable | Descripción | Default |
|----------|-------------|---------|
| `project_id` | ID del proyecto GCP | - |
| `cluster_name` | Nombre del cluster | `my-gke-cluster` |
| `region` | Región de GCP | `us-central1` |
| `enable_autopilot` | Usar modo Autopilot | `false` |
| `node_count` | Número inicial de nodos | `2` |
| `machine_type` | Tipo de máquina | `e2-medium` |

### Configuración Avanzada

#### Habilitar Binary Authorization
```hcl
enable_binary_authorization = true
```

#### Configurar Network Policies
```hcl
enable_network_policy = true
```

#### Usar Autopilot
```hcl
enable_autopilot = true
node_count = 0  # No aplica en Autopilot
```

## 🔒 Mejores Prácticas de Seguridad

### 1. Principio de Menor Privilegio
- Usa service accounts específicos para cada propósito
- Asigna solo los roles necesarios
- Rotar keys regularmente

### 2. Secrets Management
- Nunca commits keys en el código
- Usa GitHub Secrets para CI/CD
- Considera usar Google Secret Manager

### 3. Network Security
- Configura VPC nativa
- Usa network policies
- Habilita Binary Authorization

## 📊 Monitoreo y Alertas

### Métricas de Terraform
```bash
# Ver estado de recursos
terraform show

# Ver outputs
terraform output

# Ver plan de cambios
terraform plan
```

### Logs de GitHub Actions
- Accede a la pestaña **Actions** del repositorio
- Revisa logs de cada job
- Configura notificaciones por email/Slack

### Monitoreo de Costos
```bash
# Ver costos en GCP
gcloud billing accounts list
# Accede a https://console.cloud.google.com/billing
```

## 🧹 Limpieza

### Destruir Infraestructura
```bash
# Destruir todo
terraform destroy

# Destruir con auto-approve
terraform destroy -auto-approve
```

### Limpieza Manual
```bash
# Eliminar cluster
gcloud container clusters delete my-cluster --zone=us-central1-a

# Eliminar service accounts
gcloud iam service-accounts delete terraform-sa@tu-project-id.iam.gserviceaccount.com

# Eliminar bucket de estado (si usas GCS backend)
gsutil rm -r gs://my-terraform-state/
```

## 🐛 Troubleshooting

### Error: "Permission denied"
```bash
# Verificar autenticación
gcloud auth list

# Re-autenticar
gcloud auth login
```

### Error: "Quota exceeded"
```bash
# Ver cuotas
gcloud compute regions describe us-central1

# Solicitar aumento
# https://console.cloud.google.com/iam-admin/quotas
```

### Error: "Cluster not found"
```bash
# Ver clusters disponibles
gcloud container clusters list

# Verificar zona/región correcta
gcloud config get-value compute/zone
```

## 📚 Recursos Adicionales

- [Documentación Terraform GCP](https://registry.terraform.io/providers/hashicorp/google/latest)
- [GitHub Actions para GCP](https://github.com/google-github-actions)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-feature`)
3. Commit tus cambios (`git commit -am 'Agrega nueva feature'`)
4. Push a la rama (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
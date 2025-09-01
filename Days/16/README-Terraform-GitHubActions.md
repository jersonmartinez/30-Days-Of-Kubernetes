# Infraestructura AKS con Terraform y GitHub Actions

Este directorio contiene la configuración completa para desplegar y gestionar un cluster AKS usando Terraform y automatización con GitHub Actions.

## 📁 Estructura del Proyecto

```
Days/16/
├── azure-aks-management.md    # Documentación completa
├── terraform-aks/             # Configuración de Terraform
│   ├── main.tf                # Recursos principales
│   ├── variables.tf           # Variables
│   ├── outputs.tf             # Outputs
│   ├── provider.tf            # Proveedor Azure
│   └── terraform.tfvars.example # Ejemplo de variables
├── .github/
│   └── workflows/             # Workflows de GitHub Actions
│       ├── deploy-aks.yml     # Despliegue completo
│       ├── cleanup-aks.yml    # Limpieza automática
│       └── validate-aks.yml   # Validación de configuración
└── k8s/                       # Manifests de Kubernetes
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

## 🚀 Inicio Rápido

### 1. Preparar Variables de Terraform

```bash
cd terraform-aks
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

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

### 2. Configurar Autenticación Azure

#### Opción A: Service Principal (Recomendado para CI/CD)
```bash
# Crear service principal
az ad sp create-for-rbac --name "TerraformSP" --role contributor --scopes /subscriptions/<subscription-id>

# Output será similar a:
{
  "appId": "xxx",
  "displayName": "TerraformSP",
  "password": "xxx",
  "tenant": "xxx"
}
```

#### Opción B: Autenticación de Usuario (Para desarrollo local)
```bash
az login
az account set --subscription "Your Subscription Name"
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
# Obtener credenciales del cluster creado con Terraform
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw cluster_name)

# Verificar conexión
kubectl get nodes
```

## 🔧 Configuración de GitHub Actions

### Secrets Requeridos

Ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `AZURE_CREDENTIALS` | Service Principal credentials | Output de `az ad sp create-for-rbac` |
| `AZURE_RESOURCE_GROUP` | Resource Group name | Nombre del RG |
| `AZURE_CONTAINER_REGISTRY` | ACR name | Nombre del registry |
| `ACR_USERNAME` | ACR admin username | Desde Azure Portal |
| `ACR_PASSWORD` | ACR admin password | Desde Azure Portal |
| `SLACK_WEBHOOK_URL` | Slack webhook (opcional) | Crear en Slack App |

### Service Account para GitHub Actions

```bash
# Crear service principal específico para CI/CD
az ad sp create-for-rbac --name "GitHubActions" --role contributor --scopes /subscriptions/<subscription-id>

# Asignar roles específicos (principio de menor privilegio)
az role assignment create \
  --assignee <app-id> \
  --role "Kubernetes Cluster Contributor" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>
```

## 📋 Workflows Disponibles

### 1. `deploy-aks.yml` - Despliegue Completo
- **Trigger**: Push a `main` o cambios en `k8s/` o `terraform-aks/`
- **Jobs**:
  - `terraform`: Plan y apply de infraestructura
  - `build`: Construcción y push de contenedores
  - `deploy`: Despliegue de aplicaciones Kubernetes
  - `cleanup`: Limpieza de recursos antiguos

### 2. `cleanup-aks.yml` - Limpieza Automática
- **Trigger**: Programado (domingos 2 AM) o manual
- **Funciones**:
  - Eliminar pods fallidos
  - Limpiar jobs completados
  - Eliminar discos huérfanos
  - Notificaciones por Slack

### 3. `validate-aks.yml` - Validación
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
| `resource_group_name` | Nombre del Resource Group | - |
| `cluster_name` | Nombre del cluster AKS | - |
| `location` | Ubicación de Azure | `East US` |
| `kubernetes_version` | Versión de Kubernetes | `1.28.0` |
| `node_count` | Número inicial de nodos | `2` |
| `vm_size` | Tamaño de las VMs | `Standard_DS2_v2` |
| `enable_auto_scaling` | Habilitar auto-scaling | `true` |
| `enable_monitoring` | Habilitar Azure Monitor | `true` |

### Configuración Avanzada

#### Habilitar Azure Monitor
```hcl
enable_monitoring = true
```

#### Configurar Auto-scaling
```hcl
enable_auto_scaling = true
min_node_count = 1
max_node_count = 10
```

#### Usar diferentes tipos de VM
```hcl
vm_size = "Standard_D4s_v3"  # Para workloads más intensivos
```

## 🔒 Mejores Prácticas de Seguridad

### 1. Principio de Menor Privilegio
- Usa service principals específicos para cada propósito
- Asigna solo los roles necesarios
- Rotar credenciales regularmente

### 2. Network Security
- Configura Network Policies
- Usa Azure Firewall para tráfico entrante
- Implementa Azure Application Gateway WAF

### 3. Secrets Management
- Nunca commits secrets en el código
- Usa Azure Key Vault para secrets
- Implementa Azure AD Pod Identity

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
# Ver costos en Azure
az consumption usage list \
  --query "[].{Name:instanceName, Cost:pretaxCost}" \
  --output table

# Accede a https://portal.azure.com/#blade/Microsoft_Azure_Billing/ModernBillingMenuBlade/Overview
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
az aks delete --resource-group my-aks-rg --name my-aks-cluster --yes

# Eliminar resource group
az group delete --name my-aks-rg --yes

# Eliminar service principal
az ad sp delete --id <app-id>
```

## 🐛 Troubleshooting

### Error: "The client does not have authorization"
```bash
# Verificar permisos del service principal
az role assignment list --assignee <app-id> --output table

# Otorgar permisos adicionales si es necesario
az role assignment create \
  --assignee <app-id> \
  --role "Contributor" \
  --scope /subscriptions/<subscription-id>
```

### Error: "Resource quota exceeded"
```bash
# Ver cuotas actuales
az vm list-usage --location eastus --output table

# Solicitar aumento de cuota
# https://portal.azure.com/#blade/Microsoft_Azure_Capacity/QuotaMenuBlade/overview
```

### Error: "The resource provider is not registered"
```bash
# Verificar estado de providers
az provider list --query "[?registrationState!='Registered']" --output table

# Registrar provider faltante
az provider register --namespace Microsoft.ContainerService
```

### Pods en estado Pending
```bash
# Ver eventos
kubectl get events --namespace default

# Describir pod
kubectl describe pod <pod-name>
```

## 📚 Recursos Adicionales

- [Documentación AKS](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [GitHub Actions para Azure](https://github.com/Azure/actions)
- [AKS Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-feature`)
3. Commit tus cambios (`git commit -am 'Agrega nueva feature'`)
4. Push a la rama (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
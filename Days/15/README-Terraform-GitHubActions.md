# Infraestructura EKS con Terraform y GitHub Actions

Este directorio contiene la configuración completa para desplegar un cluster EKS usando Terraform y automatización con GitHub Actions.

## 📁 Estructura del Proyecto

```
Days/15/
├── aws-eks-management.md    # Documentación completa
├── terraform-eks/           # Configuración de Terraform
│   ├── main.tf              # Recursos principales
│   ├── variables.tf         # Variables
│   ├── outputs.tf           # Outputs
│   ├── provider.tf          # Proveedor AWS
│   └── terraform.tfvars.example # Ejemplo de variables
├── .github/
│   └── workflows/           # Workflows de GitHub Actions
│       ├── deploy-eks.yml   # Despliegue completo
│       ├── cleanup-eks.yml  # Limpieza automática
│       └── validate-eks.yml # Validación de configuración
└── k8s/                     # Manifests de Kubernetes
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

## 🚀 Inicio Rápido

### 1. Preparar Variables de Terraform

```bash
cd terraform-eks
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

```hcl
region            = "us-east-1"
environment       = "dev"
cluster_name      = "eks-cluster-dev"
kubernetes_version = "1.28"
vpc_cidr          = "10.0.0.0/16"
private_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
```

### 2. Configurar Autenticación AWS

#### Opción A: AWS CLI (Recomendado para desarrollo local)
```bash
# Configurar AWS CLI
aws configure

# Verificar configuración
aws sts get-caller-identity
```

#### Opción B: OIDC para GitHub Actions (Recomendado para CI/CD)
```bash
# Crear OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com

# Crear IAM role para GitHub Actions
aws iam create-role \
  --role-name GitHubActionsEKSRole \
  --assume-role-policy-document file://oidc-trust-policy.json
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
# Actualizar kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-dev

# Verificar conexión
kubectl get nodes
kubectl get pods -A
```

## 🔧 Configuración de GitHub Actions

### Secrets Requeridos

Ve a **Settings > Secrets and variables > Actions** y agrega:

| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `AWS_OIDC_ROLE_ARN` | ARN del role OIDC | Output de `aws iam create-role` |
| `AWS_REGION` | Región de AWS | `us-east-1` |
| `EKS_CLUSTER_NAME` | Nombre del cluster | `eks-cluster-dev` |
| `ECR_REPOSITORY_NAME` | Nombre del repositorio ECR | `eks-app-repo` |
| `SLACK_WEBHOOK_URL` | Webhook de Slack (opcional) | Crear en Slack App |

### Configuración de OIDC Trust Policy

Crea el archivo `oidc-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:your-org/30-Days-Of-Kubernetes:*"
        }
      }
    }
  ]
}
```

## 📋 Workflows Disponibles

### 1. `deploy-eks.yml` - Despliegue Completo
- **Trigger**: Push a `main` o cambios en `k8s/` o `terraform-eks/`
- **Jobs**:
  - `terraform`: Plan y apply de infraestructura
  - `build-and-deploy`: Construcción de contenedores y despliegue

### 2. `cleanup-eks.yml` - Limpieza Automática
- **Trigger**: Programado (domingos 2 AM UTC) o manual
- **Funciones**:
  - Eliminar pods fallidos
  - Limpiar jobs completados
  - Eliminar imágenes ECR antiguas
  - Limpiar volúmenes EBS huérfanos

### 3. `validate-eks.yml` - Validación
- **Trigger**: Push o PR a ramas principales
- **Validaciones**:
  - Sintaxis de manifests Kubernetes
  - Configuración de Terraform
  - Escaneo de seguridad con Trivy
  - Estimación de costos

## 🏗️ Personalización

### Variables de Terraform

| Variable | Descripción | Default |
|----------|-------------|---------|
| `region` | Región de AWS | `us-east-1` |
| `cluster_name` | Nombre del cluster EKS | `eks-cluster` |
| `kubernetes_version` | Versión de Kubernetes | `1.28` |
| `vpc_cidr` | CIDR block de la VPC | `10.0.0.0/16` |
| `enable_monitoring` | Habilitar CloudWatch | `true` |
| `enable_logging` | Habilitar logging del control plane | `true` |
| `enable_irsa` | Habilitar IRSA | `true` |

### Configuración Avanzada

#### Habilitar IRSA
```hcl
enable_irsa = true
```

#### Configurar Node Groups Personalizados
```hcl
node_groups = {
  general = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = 1
    max_size       = 5
    desired_size   = 2
    disk_size      = 20
  }
  spot = {
    instance_types = ["t3.medium", "t3.large"]
    capacity_type  = "SPOT"
    min_size       = 0
    max_size       = 10
    desired_size   = 0
    disk_size      = 20
  }
}
```

#### Configurar ECR
```hcl
create_ecr_repository = true
ecr_repository_name   = "my-app-repo"
```

## 🔒 Mejores Prácticas de Seguridad

### 1. Principio de Menor Privilegio
- Usa roles IAM específicos para cada servicio
- Implementa IRSA para pods
- Rotar credenciales regularmente

### 2. Network Security
- Configura security groups restrictivos
- Usa Network Policies de Kubernetes
- Implementa AWS WAF para protección

### 3. Secrets Management
- Usa AWS Secrets Manager o Parameter Store
- Implementa AWS KMS para encriptación
- Nunca commits secrets en el código

## 📊 Monitoreo y Alertas

### CloudWatch Container Insights
```bash
# Ver métricas del cluster
aws logs describe-log-groups --log-group-name-prefix /aws/eks/eks-cluster-dev

# Ver logs del control plane
aws logs tail /aws/eks/eks-cluster-dev/cluster --follow
```

### Cost Explorer
```bash
# Ver costos por servicio
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
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
aws eks delete-cluster --name eks-cluster-dev --region us-east-1

# Eliminar node groups
aws eks delete-nodegroup --cluster-name eks-cluster-dev --nodegroup-name general

# Eliminar ECR repository
aws ecr delete-repository --repository-name eks-app-repo --force

# Eliminar VPC y recursos relacionados
aws ec2 delete-vpc --vpc-id vpc-12345678
```

## 🐛 Troubleshooting

### Error: "AccessDenied"
```bash
# Verificar permisos del role
aws iam get-role --role-name GitHubActionsEKSRole

# Actualizar permisos si es necesario
aws iam attach-role-policy \
  --role-name GitHubActionsEKSRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Error: "NodeCreationFailure"
```bash
# Verificar subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-12345678"

# Verificar security groups
aws ec2 describe-security-groups --group-ids sg-12345678
```

### Pods en estado Pending
```bash
# Ver eventos
kubectl get events --sort-by=.metadata.creationTimestamp

# Describir pod
kubectl describe pod <pod-name>

# Ver logs del control plane
aws eks describe-cluster --name eks-cluster-dev --query cluster.logging
```

### Problemas de Networking
```bash
# Verificar VPC configuration
aws ec2 describe-vpc --vpc-ids vpc-12345678

# Verificar route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-12345678"

# Verificar NAT gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-12345678"
```

## 📚 Recursos Adicionales

- [Documentación EKS](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-feature`)
3. Commit tus cambios (`git commit -am 'Agrega nueva feature'`)
4. Push a la rama (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
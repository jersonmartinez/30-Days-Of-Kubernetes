# Amazon Elastic Kubernetes Service (EKS) - Gestión y Despliegues

<div align="center">

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![AWS CLI](https://img.shields.io/badge/AWS_CLI-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/cli/)

**Gestión completa de EKS con AWS CLI** 🚀
*Despliegues en la nube de Amazon*

</div>

---

## 🎯 Introducción

Amazon Elastic Kubernetes Service (EKS) es el servicio gestionado de Kubernetes de AWS. En este día aprenderás a instalar y gestionar clusters EKS usando AWS CLI, incluyendo creación, escalado, actualizaciones y despliegues de aplicaciones.

### 🌟 ¿Por qué EKS?

- ✅ **Gestionado**: AWS maneja masters y actualizaciones
- ✅ **Integración**: Nativo con servicios AWS (ECR, IAM, VPC, etc.)
- ✅ **Escalabilidad**: Auto-scaling de nodos y pods
- ✅ **Seguridad**: IAM, VPC security groups y encryption
- ✅ **Fiabilidad**: Multi-AZ y alta disponibilidad

---

## 🛠️ Prerrequisitos

### 📋 Requisitos
- Cuenta de AWS con permisos para EKS
- AWS CLI v2 instalado
- kubectl instalado
- eksctl (herramienta oficial para EKS)
- Helm (opcional para charts avanzados)

### 💰 Costos y Free Tier de AWS

#### 🎁 **AWS Free Tier (Primeros 12 meses)**
- 💰 **750 horas** de EC2 t2.micro/t3.micro al mes
- 💾 **30GB de EBS** General Purpose SSD gratuito
- ⚙️ **EKS gratuito** durante los primeros 12 meses (solo paga por nodos worker)
- 🌐 **5GB de transferencia** de datos salientes gratuita

#### 💸 **¿Qué genera costos en EKS?**

| 🔧 Servicio | 💵 Costo Estimado | 🎯 Free Tier | ⚠️ Notas |
|-------------|-------------------|--------------|----------|
| **🖥️ Nodos EC2** | $0.0116-0.096/hora | ✅ Parcial (750h/mes) | Según tipo de instancia |
| **🎛️ Control Plane** | $0.10/hora | ✅ Gratuito 12 meses | Gestionado por AWS |
| **🌐 Load Balancer** | $0.0225/hora (~$16/mes) | ❌ No incluido | Application/Network Load Balancer |
| **💾 Storage EBS** | $0.10/GB/mes | ✅ Parcial (30GB) | Para Persistent Volumes |
| **📤 Network Egress** | $0.09/GB | ✅ Parcial (5GB) | Tráfico saliente |
| **📊 CloudWatch** | $0.30/GB logs | ❌ No incluido | Para monitoring avanzado |

#### 🚨 **Costos Comunes que pueden sorprenderte**

| 🚨 Problema | 💵 Costo Típico | 🔍 Cómo Detectarlo | 🛠️ Solución |
|-------------|------------------|-------------------|-------------|
| **Load Balancers olvidados** | $16/mes cada uno | `aws elbv2 describe-load-balancers` | Eliminar con `kubectl delete svc` |
| **NAT Gateway** | $32/mes por zona | `aws ec2 describe-nat-gateways` | Usar VPC privada sin NAT |
| **EBS no utilizado** | $0.10/GB/mes | `aws ec2 describe-volumes` | Eliminar PVs antes del cluster |
| **Cross-AZ traffic** | $0.02/GB | CloudWatch → Network | Configurar pods en misma AZ |

#### 💡 **Estrategias para minimizar costos durante pruebas**

```bash
# 🆓 Usar instancias dentro del free tier
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --node-type t3.micro \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 2

# 🔄 Evitar LoadBalancer para pruebas (usar ClusterIP)
kubectl expose deployment nginx --port=80 --type=ClusterIP

# 🌐 Para acceso externo temporal, usar port-forwarding
kubectl port-forward svc/my-service 8080:80

# 💰 Monitorear costos en tiempo real
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

#### 📊 **Ejemplo de costo diario típico para pruebas**

| ⚙️ Configuración | 💵 Costo Diario | 🎯 Recomendado para |
|------------------|-----------------|---------------------|
| **1 nodo t3.micro básico** | $0.20-0.30/día | ✅ Pruebas simples (Free Tier) |
| **2 nodos t3.small + LB** | $1-2/día | ⚠️ Pruebas con servicios |
| **Auto-scaling 1-3 nodos** | $1-3/día | ⚠️ Pruebas de escalado |
| **Con monitoring completo** | $2-5/día | ❌ Producción ligera |

**💡 Tip**: Para pruebas puramente educativas, considera usar Minikube o Kind en tu máquina local en lugar de EKS, ya que son completamente gratuitos.

---

## 🚀 Instalación y Configuración

### 1. Instalar AWS CLI v2

#### En Windows/WSL:
```bash
# Descargar instalador
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Descomprimir e instalar
unzip awscliv2.zip
sudo ./aws/install

# Verificar
aws --version
```

#### En macOS:
```bash
brew install awscli
```

#### En Linux:
```bash
# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 2. Instalar eksctl

```bash
# Descargar y instalar
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verificar
eksctl version
```

### 3. Configurar Credenciales AWS

```bash
# Configurar con access keys
aws configure

# O usar profiles
aws configure --profile my-profile

# Ver perfiles
aws configure list-profiles
```

### 4. Instalar kubectl

```bash
# Descargar
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Hacer ejecutable
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verificar
kubectl version --client
```

---

## 📦 Creación de Cluster EKS

### Crear Cluster con eksctl (Recomendado)

```bash
# Variables
CLUSTER_NAME="my-eks-cluster"
REGION="us-east-1"

# Crear cluster básico
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

### Opciones Avanzadas

```bash
# Cluster con configuración avanzada
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --version 1.28 \
  --vpc-private-subnets subnet-12345,subnet-67890 \
  --nodegroup-name ng-1 \
  --node-type t3.large \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 10 \
  --managed \
  --asg-access \
  --external-dns-access \
  --full-ecr-access \
  --alb-ingress-access \
  --cluster-autoscaler-access
```

### Crear Cluster con AWS CLI (Avanzado)

```bash
# Crear role para EKS
aws iam create-role \
  --role-name eks-service-role \
  --assume-role-policy-document file://eks-service-role.json

# Adjuntar policy
aws iam attach-role-policy \
  --role-name eks-service-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Crear cluster
aws eks create-cluster \
  --name $CLUSTER_NAME \
  --role-arn arn:aws:iam::123456789012:role/eks-service-role \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890

# Crear nodegroup
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name my-nodegroup \
  --subnets subnet-12345 subnet-67890 \
  --node-role arn:aws:iam::123456789012:role/NodeInstanceRole \
  --instance-types t3.medium
```

### Conectar kubectl al Cluster

```bash
# Con eksctl
eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME --region=$REGION

# O con AWS CLI
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verificar
kubectl get nodes
kubectl cluster-info
```

---

## 📊 Gestión del Cluster

### Escalado de Nodos

```bash
# Escalar nodegroup
eksctl scale nodegroup \
  --cluster=$CLUSTER_NAME \
  --nodes=5 \
  --name=standard-workers \
  --nodes-min=1 \
  --nodes-max=10

# Ver estado
eksctl get nodegroups --cluster=$CLUSTER_NAME
```

### Actualización de Kubernetes

```bash
# Ver versiones disponibles
aws eks describe-cluster --name $CLUSTER_NAME --query cluster.version

# Actualizar control plane
aws eks update-cluster-version --name $CLUSTER_NAME --version 1.28

# Actualizar nodegroups
eksctl upgrade nodegroup \
  --cluster=$CLUSTER_NAME \
  --name=standard-workers \
  --kubernetes-version=1.28
```

### Monitoreo Básico

```bash
# Ver estado del cluster
aws eks describe-cluster --name $CLUSTER_NAME

# Ver nodegroups
aws eks list-nodegroups --cluster-name $CLUSTER_NAME

# Ver add-ons
aws eks list-addons --cluster-name $CLUSTER_NAME
```

---

## 🚀 Despliegues en EKS

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
  name: hello-eks
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-eks
  template:
    metadata:
      labels:
        app: hello-eks
    spec:
      containers:
      - name: hello-eks
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello-eks-svc
  namespace: demo
spec:
  selector:
    app: hello-eks
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

### ❌ Error: "AccessDenied"

```bash
# Verificar permisos IAM
aws sts get-caller-identity

# Adjuntar policy necesaria
aws iam attach-user-policy \
  --user-name <username> \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
```

### ❌ Error: "InsufficientCapacity"

```bash
# Cambiar zona de disponibilidad
eksctl create cluster --name $CLUSTER_NAME --region us-west-2

# O usar diferentes tipos de instancia
eksctl create cluster --name $CLUSTER_NAME --node-type t3.small
```

### ❌ Nodes no se unen al cluster

```bash
# Verificar configuración de red
kubectl get nodes
kubectl describe node <node-name>

# Ver logs de kubelet
ssh ec2-user@<node-ip> journalctl -u kubelet
```

### ❌ LoadBalancer no obtiene IP

```bash
# Ver eventos del servicio
kubectl describe svc <service-name> --namespace demo

# Verificar subnets públicas
aws ec2 describe-subnets --subnet-ids <subnet-id>
```

---

## 📈 Mejores Prácticas DevOps

### 🔒 **Security**
- Usar IAM roles para service accounts (IRSA)
- Configurar VPC security groups
- Habilitar encryption at rest
- Usar AWS Config para compliance

### 🚀 **CI/CD Integration**
```yaml
# Ejemplo GitHub Actions
- name: Deploy to EKS
  run: |
    aws eks update-kubeconfig --name ${{ env.CLUSTER_NAME }}
    kubectl apply -f k8s/
    kubectl rollout status deployment/my-app
```

### 📊 **Monitoring**
- CloudWatch para métricas
- CloudTrail para auditoría
- X-Ray para tracing
- Prometheus + Grafana para monitoreo avanzado

### 💰 **Cost Optimization**
- Usar spot instances
- Reserved instances para producción
- Auto-scaling basado en métricas
- Cluster hibernation para desarrollo

---

## 🧹 Limpieza

```bash
# Eliminar cluster con eksctl
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

# O con AWS CLI
aws eks delete-cluster --name $CLUSTER_NAME --region $REGION
aws ec2 delete-key-pair --key-name my-keypair
```

---

## 🎯 Próximos Pasos

- **Día 16**: Azure Kubernetes Service (AKS)
- **Día 17**: Google Kubernetes Engine (GKE)
- **Proyecto**: Multi-cloud deployment

### 📚 Recursos Adicionales

- [Documentación EKS](https://docs.aws.amazon.com/eks/)
- [eksctl Documentation](https://eksctl.io/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

---

<div align="center">

### 💡 **Recuerda**: EKS ofrece la madurez y escalabilidad de AWS

**¿Listo para Azure?** → [Día 16](../16/)

</div>
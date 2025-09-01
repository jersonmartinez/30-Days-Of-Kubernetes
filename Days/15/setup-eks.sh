#!/bin/bash

# Script de configuración inicial para EKS
# Este script automatiza la configuración inicial del cluster EKS

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    print_message "Verificando dependencias..."

    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI no está instalado. Instálalo desde: https://aws.amazon.com/cli/"
        exit 1
    fi

    if ! command -v terraform &> /dev/null; then
        print_error "Terraform no está instalado. Instálalo desde: https://www.terraform.io/downloads"
        exit 1
    fi

    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl no está instalado. Instálalo desde: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi

    print_success "Todas las dependencias están instaladas"
}

# Configurar AWS CLI
setup_aws_cli() {
    print_message "Configurando AWS CLI..."

    if ! aws sts get-caller-identity &> /dev/null; then
        print_warning "AWS CLI no está configurado. Ejecutando 'aws configure'..."
        aws configure
    fi

    # Verificar configuración
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region)

    print_success "AWS CLI configurado para cuenta: $ACCOUNT_ID en región: $REGION"
}

# Crear bucket S3 para Terraform state (opcional)
create_s3_bucket() {
    print_message "Creando bucket S3 para Terraform state..."

    BUCKET_NAME="terraform-state-eks-$(date +%s)"
    REGION=$(aws configure get region)

    if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
        aws s3 mb s3://$BUCKET_NAME --region $REGION
        print_success "Bucket S3 creado: $BUCKET_NAME"
    else
        print_warning "Bucket S3 ya existe: $BUCKET_NAME"
    fi

    echo $BUCKET_NAME
}

# Configurar variables de Terraform
setup_terraform_vars() {
    print_message "Configurando variables de Terraform..."

    cd terraform-eks

    if [ ! -f "terraform.tfvars" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_success "Archivo terraform.tfvars creado"
    else
        print_warning "Archivo terraform.tfvars ya existe"
    fi

    # Preguntar por configuración personalizada
    read -p "Ingresa el nombre del cluster [eks-cluster-dev]: " CLUSTER_NAME
    CLUSTER_NAME=${CLUSTER_NAME:-eks-cluster-dev}

    read -p "Ingresa la región [$REGION]: " TF_REGION
    TF_REGION=${TF_REGION:-$REGION}

    # Actualizar variables
    sed -i "s/cluster_name = \".*\"/cluster_name = \"$CLUSTER_NAME\"/g" terraform.tfvars
    sed -i "s/region = \".*\"/region = \"$TF_REGION\"/g" terraform.tfvars

    print_success "Variables de Terraform configuradas"
    cd ..
}

# Inicializar Terraform
init_terraform() {
    print_message "Inicializando Terraform..."

    cd terraform-eks
    terraform init
    print_success "Terraform inicializado"
    cd ..
}

# Plan de Terraform
plan_terraform() {
    print_message "Generando plan de Terraform..."

    cd terraform-eks
    terraform plan -out=tfplan
    print_success "Plan de Terraform generado"
    cd ..
}

# Aplicar configuración
apply_terraform() {
    print_message "Aplicando configuración de Terraform..."

    cd terraform-eks
    terraform apply tfplan
    print_success "Configuración aplicada exitosamente"
    cd ..
}

# Configurar kubectl
setup_kubectl() {
    print_message "Configurando kubectl..."

    CLUSTER_NAME=$(grep 'cluster_name' terraform-eks/terraform.tfvars | cut -d'"' -f2)
    REGION=$(grep 'region' terraform-eks/terraform.tfvars | cut -d'"' -f2)

    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    print_success "kubectl configurado para cluster: $CLUSTER_NAME"
}

# Verificar cluster
verify_cluster() {
    print_message "Verificando cluster EKS..."

    # Esperar a que los nodos estén ready
    print_message "Esperando a que los nodos estén listos..."
    kubectl wait --for=condition=Ready nodes --all --timeout=600s

    # Ver información del cluster
    kubectl get nodes
    kubectl get pods -A

    print_success "Cluster EKS verificado y funcionando"
}

# Función principal
main() {
    echo "🚀 Configuración inicial de EKS"
    echo "================================"

    check_dependencies
    setup_aws_cli

    read -p "¿Crear bucket S3 para Terraform state? (y/n): " CREATE_BUCKET
    if [[ $CREATE_BUCKET =~ ^[Yy]$ ]]; then
        BUCKET_NAME=$(create_s3_bucket)
        print_message "Bucket S3 creado: $BUCKET_NAME"
    fi

    setup_terraform_vars
    init_terraform

    read -p "¿Generar plan de Terraform? (y/n): " GENERATE_PLAN
    if [[ $GENERATE_PLAN =~ ^[Yy]$ ]]; then
        plan_terraform
    fi

    read -p "¿Aplicar configuración de Terraform? (y/n): " APPLY_CONFIG
    if [[ $APPLY_CONFIG =~ ^[Yy]$ ]]; then
        apply_terraform
        setup_kubectl
        verify_cluster
    fi

    echo ""
    print_success "Configuración inicial completada!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Revisa la documentación en README-Terraform-GitHubActions.md"
    echo "2. Configura GitHub Actions secrets si vas a usar CI/CD"
    echo "3. Despliega tu aplicación usando los manifests en k8s/"
    echo "4. Configura monitoreo y alertas según sea necesario"
}

# Ejecutar función principal
main "$@"
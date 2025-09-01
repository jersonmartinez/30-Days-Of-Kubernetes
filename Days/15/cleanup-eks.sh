#!/bin/bash

# Script de limpieza para EKS
# Este script automatiza la limpieza de recursos EKS

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

# Función para confirmar acciones destructivas
confirm_action() {
    local message=$1
    read -p "$message (y/n): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        print_message "Operación cancelada"
        exit 0
    fi
}

# Limpiar recursos de Kubernetes
cleanup_kubernetes() {
    print_message "🧹 Limpiando recursos de Kubernetes..."

    # Eliminar deployments y servicios
    kubectl delete deployment --all --ignore-not-found=true
    kubectl delete service --all --ignore-not-found=true
    kubectl delete ingress --all --ignore-not-found=true
    kubectl delete configmap --all --ignore-not-found=true
    kubectl delete secret --all --ignore-not-found=true

    # Eliminar jobs completados
    kubectl delete jobs --field-selector=status.successful=1 --ignore-not-found=true

    # Eliminar pods fallidos
    kubectl delete pods --field-selector=status.phase=Failed --ignore-not-found=true

    # Limpiar PVCs huérfanos
    kubectl delete pvc --field-selector=status.phase=Lost --ignore-not-found=true

    print_success "Recursos de Kubernetes limpiados"
}

# Limpiar ECR
cleanup_ecr() {
    print_message "🗑️ Limpiando ECR..."

    # Obtener lista de repositorios
    REPOS=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text 2>/dev/null || echo "")

    if [ -z "$REPOS" ]; then
        print_warning "No se encontraron repositorios ECR"
        return
    fi

    for REPO in $REPOS; do
        print_message "Procesando repositorio: $REPO"

        # Obtener imágenes (excluyendo las últimas 5)
        IMAGES_TO_DELETE=$(aws ecr list-images --repository-name $REPO --query 'imageIds[5:].imageDigest' --output text 2>/dev/null || echo "")

        if [ ! -z "$IMAGES_TO_DELETE" ]; then
            # Crear archivo temporal con las imágenes a eliminar
            echo "$IMAGES_TO_DELETE" | tr ' ' '\n' | while read IMAGE_ID; do
                echo "{\"imageDigest\":\"$IMAGE_ID\"}"
            done > /tmp/images-to-delete.json

            # Eliminar imágenes
            aws ecr batch-delete-image --repository-name $REPO --image-ids file:///tmp/images-to-delete.json

            print_success "Imágenes antiguas eliminadas de $REPO"
        else
            print_message "No hay imágenes antiguas para eliminar en $REPO"
        fi
    done

    # Limpiar archivo temporal
    rm -f /tmp/images-to-delete.json
}

# Limpiar volúmenes EBS
cleanup_ebs() {
    print_message "💾 Limpiando volúmenes EBS..."

    # Encontrar volúmenes disponibles
    UNUSED_VOLUMES=$(aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].VolumeId' --output text 2>/dev/null || echo "")

    if [ -z "$UNUSED_VOLUMES" ]; then
        print_warning "No se encontraron volúmenes EBS disponibles"
        return
    fi

    print_warning "Volúmenes EBS disponibles encontrados: $UNUSED_VOLUMES"

    for VOLUME in $UNUSED_VOLUMES; do
        read -p "¿Eliminar volumen $VOLUME? (y/n): " DELETE_VOLUME
        if [[ $DELETE_VOLUME =~ ^[Yy]$ ]]; then
            aws ec2 delete-volume --volume-id $VOLUME
            print_success "Volumen $VOLUME eliminado"
        fi
    done
}

# Limpiar Load Balancers
cleanup_load_balancers() {
    print_message "⚖️ Limpiando Load Balancers..."

    # Encontrar load balancers
    LBS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null || echo "")

    if [ -z "$LBS" ]; then
        print_warning "No se encontraron Load Balancers"
        return
    fi

    for LB_ARN in $LBS; do
        LB_NAME=$(aws elbv2 describe-load-balancers --load-balancer-arns $LB_ARN --query 'LoadBalancers[0].LoadBalancerName' --output text)

        read -p "¿Eliminar Load Balancer $LB_NAME? (y/n): " DELETE_LB
        if [[ $DELETE_LB =~ ^[Yy]$ ]]; then
            # Eliminar listeners primero
            LISTENERS=$(aws elbv2 describe-listeners --load-balancer-arn $LB_ARN --query 'Listeners[].ListenerArn' --output text)
            for LISTENER in $LISTENERS; do
                aws elbv2 delete-listener --listener-arn $LISTENER
            done

            # Eliminar load balancer
            aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
            print_success "Load Balancer $LB_NAME eliminado"
        fi
    done
}

# Limpiar CloudWatch logs
cleanup_cloudwatch() {
    print_message "📊 Limpiando CloudWatch logs..."

    # Obtener log groups con retención > 30 días
    LOG_GROUPS=$(aws logs describe-log-groups --query 'logGroups[?retentionInDays>`30`].logGroupName' --output text 2>/dev/null || echo "")

    if [ -z "$LOG_GROUPS" ]; then
        print_warning "No se encontraron log groups con retención > 30 días"
        return
    fi

    for LOG_GROUP in $LOG_GROUPS; do
        read -p "¿Cambiar retención de $LOG_GROUP a 30 días? (y/n): " CHANGE_RETENTION
        if [[ $CHANGE_RETENTION =~ ^[Yy]$ ]]; then
            aws logs put-retention-policy --log-group-name $LOG_GROUP --retention-in-days 30
            print_success "Retención de $LOG_GROUP cambiada a 30 días"
        fi
    done
}

# Destruir infraestructura con Terraform
destroy_terraform() {
    print_message "🏗️ Destruyendo infraestructura con Terraform..."

    cd terraform-eks

    # Verificar que existe el estado
    if [ ! -f ".terraform/terraform.tfstate" ]; then
        print_error "No se encontró el estado de Terraform. Ejecuta 'terraform init' primero"
        cd ..
        return
    fi

    # Generar plan de destrucción
    terraform plan -destroy -out=destroy.tfplan

    # Aplicar destrucción
    terraform apply destroy.tfplan

    print_success "Infraestructura destruida"
    cd ..
}

# Función principal
main() {
    echo "🧹 Limpieza de EKS"
    echo "=================="

    # Verificar que estamos en el directorio correcto
    if [ ! -d "terraform-eks" ]; then
        print_error "Este script debe ejecutarse desde el directorio raíz del proyecto EKS"
        exit 1
    fi

    echo "Selecciona el tipo de limpieza:"
    echo "1) Limpieza ligera (Kubernetes resources)"
    echo "2) Limpieza completa (ECR, EBS, Load Balancers)"
    echo "3) Destruir toda la infraestructura (Terraform destroy)"
    echo "4) Limpieza personalizada"
    read -p "Opción (1-4): " CLEANUP_TYPE

    case $CLEANUP_TYPE in
        1)
            confirm_action "¿Proceder con limpieza ligera de Kubernetes?"
            cleanup_kubernetes
            ;;
        2)
            confirm_action "¿Proceder con limpieza completa?"
            cleanup_kubernetes
            cleanup_ecr
            cleanup_ebs
            cleanup_load_balancers
            cleanup_cloudwatch
            ;;
        3)
            confirm_action "¿Destruir TODA la infraestructura? Esta acción no se puede deshacer"
            destroy_terraform
            ;;
        4)
            echo "Selecciona qué limpiar:"
            read -p "¿Limpiar recursos Kubernetes? (y/n): " CLEAN_K8S
            if [[ $CLEAN_K8S =~ ^[Yy]$ ]]; then cleanup_kubernetes; fi

            read -p "¿Limpiar ECR? (y/n): " CLEAN_ECR
            if [[ $CLEAN_ECR =~ ^[Yy]$ ]]; then cleanup_ecr; fi

            read -p "¿Limpiar EBS? (y/n): " CLEAN_EBS
            if [[ $CLEAN_EBS =~ ^[Yy]$ ]]; then cleanup_ebs; fi

            read -p "¿Limpiar Load Balancers? (y/n): " CLEAN_LB
            if [[ $CLEAN_LB =~ ^[Yy]$ ]]; then cleanup_load_balancers; fi

            read -p "¿Limpiar CloudWatch? (y/n): " CLEAN_CW
            if [[ $CLEAN_CW =~ ^[Yy]$ ]]; then cleanup_cloudwatch; fi
            ;;
        *)
            print_error "Opción inválida"
            exit 1
            ;;
    esac

    echo ""
    print_success "Limpieza completada!"
    echo ""
    echo "💡 Recomendaciones:"
    echo "- Revisa la consola de AWS para verificar que todos los recursos se eliminaron"
    echo "- Si usas Terraform, considera hacer 'terraform destroy' para eliminar todo"
    echo "- Revisa los costos en AWS Cost Explorer para confirmar la limpieza"
}

# Ejecutar función principal
main "$@"
#!/bin/bash

# ===================================================================
# Minikube Production-Ready Setup Script - Día 1
# Instalación y configuración completa de Minikube con optimizaciones
# ===================================================================

set -euo pipefail

# Colores y configuración
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración por defecto
MINIKUBE_VERSION="v1.32.0"
KUBECTL_VERSION="v1.28.0"
DRIVER="docker"
CPUS="4"
MEMORY="8192"
DISK_SIZE="50g"
CLUSTER_NAME="minikube"

# Funciones de utilidad
print_header() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}===================================================${NC}\n"
}

print_step() {
    echo -e "${GREEN}➤ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detectar arquitectura
detect_arch() {
    case $(uname -m) in
        x86_64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "amd64" ;;
    esac
}

# Verificar prerrequisitos del sistema
check_system_requirements() {
    print_header "Verificando Prerrequisitos del Sistema"
    
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    print_step "Sistema detectado: $os ($arch)"
    
    # Verificar memoria disponible
    if [[ "$os" == "linux" ]]; then
        local mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local mem_total_gb=$((mem_total_kb / 1024 / 1024))
        
        if [ "$mem_total_gb" -lt 4 ]; then
            print_error "Se requieren al menos 4GB de RAM. Detectado: ${mem_total_gb}GB"
            return 1
        fi
        print_success "Memoria disponible: ${mem_total_gb}GB"
        
        # Verificar espacio en disco
        local disk_space=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
        if [ "$disk_space" -lt 20 ]; then
            print_error "Se requieren al menos 20GB de espacio libre. Disponible: ${disk_space}GB"
            return 1
        fi
        print_success "Espacio en disco: ${disk_space}GB disponibles"
        
    elif [[ "$os" == "darwin" ]]; then
        local mem_total_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
        if [ "$mem_total_gb" -lt 8 ]; then
            print_warning "macOS con menos de 8GB puede tener problemas de rendimiento"
        fi
        print_success "Memoria disponible: ${mem_total_gb}GB"
    fi
    
    # Verificar virtualización
    if [[ "$os" == "linux" ]]; then
        if grep -q vmx /proc/cpuinfo || grep -q svm /proc/cpuinfo; then
            print_success "Virtualización habilitada"
        else
            print_warning "Virtualización no detectada. Verificar BIOS/UEFI"
        fi
    fi
    
    return 0
}

# Instalar Docker si no está presente
install_docker() {
    print_header "Verificando Docker"
    
    if command -v docker &> /dev/null; then
        print_success "Docker ya está instalado: $(docker --version)"
        
        # Verificar que Docker esté ejecutándose
        if ! docker info &> /dev/null; then
            print_warning "Docker no está ejecutándose. Intentando iniciar..."
            if [[ $(detect_os) == "linux" ]]; then
                sudo systemctl start docker
                sudo systemctl enable docker
            elif [[ $(detect_os) == "darwin" ]]; then
                open -a Docker
                print_info "Docker Desktop iniciándose... esperando 30 segundos"
                sleep 30
            fi
        fi
        
        # Verificar permisos de Docker
        if ! docker ps &> /dev/null; then
            print_warning "Sin permisos para Docker. Configurando usuario..."
            if [[ $(detect_os) == "linux" ]]; then
                sudo usermod -aG docker $USER
                print_info "Logout y login nuevamente para aplicar permisos de Docker"
                print_info "O ejecuta: newgrp docker"
            fi
        fi
        
        return 0
    fi
    
    print_step "Instalando Docker..."
    
    local os=$(detect_os)
    
    case $os in
        "linux")
            # Detectar distribución
            if [ -f /etc/debian_version ]; then
                print_info "Detectado sistema Debian/Ubuntu"
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                
            elif [ -f /etc/redhat-release ]; then
                print_info "Detectado sistema Red Hat/CentOS/Fedora"
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io
            fi
            
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
            
        "darwin")
            print_info "Para macOS, descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop"
            print_info "O instala con Homebrew: brew install --cask docker"
            return 1
            ;;
            
        *)
            print_error "Sistema operativo no soportado para instalación automática"
            return 1
            ;;
    esac
    
    print_success "Docker instalado correctamente"
}

# Instalar kubectl
install_kubectl() {
    print_header "Instalando kubectl"
    
    if command -v kubectl &> /dev/null; then
        local current_version=$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')
        print_success "kubectl ya está instalado: $current_version"
        return 0
    fi
    
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    print_step "Descargando kubectl $KUBECTL_VERSION..."
    
    case $os in
        "linux"|"darwin")
            curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${os}/${arch}/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            ;;
        "windows")
            curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/windows/${arch}/kubectl.exe"
            print_info "Mueve kubectl.exe a un directorio en tu PATH"
            ;;
    esac
    
    print_success "kubectl $KUBECTL_VERSION instalado"
}

# Instalar Minikube
install_minikube() {
    print_header "Instalando Minikube"
    
    if command -v minikube &> /dev/null; then
        local current_version=$(minikube version --short)
        print_success "Minikube ya está instalado: $current_version"
        return 0
    fi
    
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    print_step "Descargando Minikube $MINIKUBE_VERSION..."
    
    case $os in
        "linux")
            curl -LO "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-${arch}"
            chmod +x minikube-linux-${arch}
            sudo mv minikube-linux-${arch} /usr/local/bin/minikube
            ;;
        "darwin")
            curl -LO "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-darwin-${arch}"
            chmod +x minikube-darwin-${arch}
            sudo mv minikube-darwin-${arch} /usr/local/bin/minikube
            ;;
        "windows")
            curl -LO "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-windows-${arch}.exe"
            print_info "Mueve minikube-windows-${arch}.exe a un directorio en tu PATH como minikube.exe"
            ;;
    esac
    
    print_success "Minikube $MINIKUBE_VERSION instalado"
}

# Configurar y iniciar Minikube
start_minikube() {
    print_header "Configurando e Iniciando Minikube"
    
    # Verificar si ya está ejecutándose
    if minikube status &> /dev/null; then
        print_info "Minikube ya está ejecutándose"
        minikube status
        return 0
    fi
    
    print_step "Configurando Minikube con las siguientes especificaciones:"
    echo "   🚀 Driver: $DRIVER"
    echo "   💾 Memoria: ${MEMORY}MB"
    echo "   🔧 CPUs: $CPUS"
    echo "   💿 Disco: $DISK_SIZE"
    echo "   📛 Nombre: $CLUSTER_NAME"
    
    # Configurar driver basado en el sistema
    local os=$(detect_os)
    case $os in
        "linux")
            # Verificar drivers disponibles
            if command -v docker &> /dev/null && docker info &> /dev/null; then
                DRIVER="docker"
            elif command -v kvm2 &> /dev/null; then
                DRIVER="kvm2"
            elif command -v virtualbox &> /dev/null; then
                DRIVER="virtualbox"
            fi
            ;;
        "darwin")
            if command -v docker &> /dev/null; then
                DRIVER="docker"
            elif [ -d "/Applications/VirtualBox.app" ]; then
                DRIVER="virtualbox"
            elif command -v hyperkit &> /dev/null; then
                DRIVER="hyperkit"
            fi
            ;;
    esac
    
    print_info "Driver seleccionado: $DRIVER"
    
    # Iniciar Minikube con configuración optimizada
    print_step "Iniciando Minikube (esto puede tomar varios minutos)..."
    
    minikube start \
        --driver="$DRIVER" \
        --cpus="$CPUS" \
        --memory="$MEMORY" \
        --disk-size="$DISK_SIZE" \
        --kubernetes-version="$KUBECTL_VERSION" \
        --container-runtime=containerd \
        --feature-gates="EphemeralContainers=true" \
        --extra-config=kubelet.housekeeping-interval=10s \
        --extra-config=kubelet.image-gc-high-threshold=95 \
        --extra-config=kubelet.image-gc-low-threshold=90 \
        --extra-config=apiserver.enable-admission-plugins="NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook" \
        -p "$CLUSTER_NAME"
    
    print_success "Minikube iniciado correctamente"
    
    # Verificar estado
    print_step "Verificando estado del cluster"
    minikube status -p "$CLUSTER_NAME"
    
    # Configurar kubectl context
    kubectl config use-context "$CLUSTER_NAME"
    print_success "Context de kubectl configurado: $CLUSTER_NAME"
}

# Instalar addons esenciales
install_addons() {
    print_header "Instalando Addons Esenciales"
    
    local addons=(
        "metrics-server"
        "dashboard"
        "ingress"
        "registry"
        "storage-provisioner"
        "default-storageclass"
    )
    
    for addon in "${addons[@]}"; do
        print_step "Habilitando addon: $addon"
        if minikube addons enable "$addon" -p "$CLUSTER_NAME"; then
            print_success "Addon $addon habilitado"
        else
            print_warning "No se pudo habilitar addon: $addon"
        fi
    done
    
    # Esperar a que los pods estén listos
    print_step "Esperando a que los addons estén listos..."
    kubectl wait --for=condition=ready pod --all -n kube-system --timeout=300s
    
    print_success "Todos los addons están listos"
}

# Configurar herramientas adicionales
setup_additional_tools() {
    print_header "Configurando Herramientas Adicionales"
    
    # Instalar k9s para management
    print_step "Instalando k9s (Kubernetes CLI UI)"
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    case $os in
        "linux")
            curl -sS https://webi.sh/k9s | sh
            ;;
        "darwin")
            if command -v brew &> /dev/null; then
                brew install k9s
            else
                curl -sS https://webi.sh/k9s | sh
            fi
            ;;
    esac
    
    # Configurar aliases útiles
    print_step "Configurando aliases de kubectl"
    
    cat > ~/.kubectl_aliases << 'EOF'
# Kubectl aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kaf='kubectl apply -f'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias klogs='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'
EOF
    
    # Agregar a bashrc/zshrc si no existe
    if ! grep -q "kubectl_aliases" ~/.bashrc 2>/dev/null; then
        echo "source ~/.kubectl_aliases" >> ~/.bashrc
    fi
    
    if ! grep -q "kubectl_aliases" ~/.zshrc 2>/dev/null; then
        echo "source ~/.kubectl_aliases" >> ~/.zshrc
    fi
    
    print_success "Aliases configurados"
    
    # Configurar autocompletado
    print_step "Configurando autocompletado de kubectl"
    kubectl completion bash > ~/.kubectl_completion
    
    if ! grep -q "kubectl_completion" ~/.bashrc 2>/dev/null; then
        echo "source ~/.kubectl_completion" >> ~/.bashrc
    fi
    
    print_success "Autocompletado configurado"
}

# Crear ejemplos y demos
create_examples() {
    print_header "Creando Ejemplos de Demostración"
    
    local examples_dir="$HOME/kubernetes-examples"
    mkdir -p "$examples_dir"
    
    # Ejemplo 1: Pod simple
    cat > "$examples_dir/01-simple-pod.yaml" << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  labels:
    app: demo
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "50m"
      limits:
        memory: "128Mi"
        cpu: "100m"
EOF
    
    # Ejemplo 2: Deployment con Service
    cat > "$examples_dir/02-deployment-service.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
EOF
    
    # Ejemplo 3: ConfigMap y Secret
    cat > "$examples_dir/03-configmap-secret.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgres://localhost:5432/app"
  debug_mode: "false"
  max_connections: "100"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  db_password: cGFzc3dvcmQxMjM=  # password123 en base64
  api_key: YWJjZGVmZ2hpams=      # abcdefghijk en base64
EOF
    
    # Script de demo
    cat > "$examples_dir/demo.sh" << 'EOF'
#!/bin/bash

echo "🚀 Kubernetes Demo Script"

echo "1. Aplicando Pod simple..."
kubectl apply -f 01-simple-pod.yaml

echo "2. Esperando que el Pod esté listo..."
kubectl wait --for=condition=ready pod/simple-pod --timeout=60s

echo "3. Mostrando información del Pod..."
kubectl get pod simple-pod -o wide

echo "4. Aplicando Deployment y Service..."
kubectl apply -f 02-deployment-service.yaml

echo "5. Esperando que el Deployment esté listo..."
kubectl wait --for=condition=available deployment/web-app --timeout=120s

echo "6. Mostrando recursos creados..."
kubectl get deployments,services,pods

echo "7. Obteniendo URL del servicio..."
minikube service web-app-service --url

echo "✅ Demo completada. Para limpiar ejecuta:"
echo "kubectl delete -f ."
EOF
    
    chmod +x "$examples_dir/demo.sh"
    
    print_success "Ejemplos creados en: $examples_dir"
    print_info "Ejecuta: cd $examples_dir && ./demo.sh"
}

# Verificar instalación completa
verify_installation() {
    print_header "Verificando Instalación Completa"
    
    # Verificar versiones
    print_step "Versiones instaladas:"
    echo "   🐳 Docker: $(docker --version)"
    echo "   ☸️  kubectl: $(kubectl version --client --short)"
    echo "   🎛️  Minikube: $(minikube version --short)"
    
    # Verificar cluster
    print_step "Estado del cluster:"
    kubectl cluster-info
    
    # Verificar nodos
    print_step "Nodos disponibles:"
    kubectl get nodes -o wide
    
    # Verificar addons
    print_step "Addons habilitados:"
    minikube addons list -p "$CLUSTER_NAME" | grep enabled
    
    # Test básico
    print_step "Ejecutando test básico..."
    kubectl run test-pod --image=nginx:alpine --rm -it --restart=Never -- echo "Test exitoso"
    
    print_success "Instalación verificada correctamente"
}

# Mostrar información post-instalación
show_post_install_info() {
    print_header "Información Post-Instalación"
    
    print_step "Comandos útiles:"
    echo "   🎛️  Dashboard: minikube dashboard"
    echo "   🔧 SSH al nodo: minikube ssh"
    echo "   📊 Métricas: kubectl top nodes"
    echo "   🔍 Ver logs: kubectl logs -f <pod-name>"
    echo "   🌐 Tunnel services: minikube tunnel"
    
    print_step "URLs importantes:"
    echo "   📊 Dashboard: http://$(minikube ip):30000"
    echo "   🎯 API Server: $(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
    
    print_step "Próximos pasos:"
    echo "   1. Explorar: cd $HOME/kubernetes-examples && ./demo.sh"
    echo "   2. Dashboard: minikube dashboard"
    echo "   3. Continuar con Día 2: Implementando aplicaciones"
    
    print_info "Para ayuda: kubectl --help o minikube --help"
    print_info "Documentación: https://kubernetes.io/docs/"
}

# Función principal
main() {
    clear
    
    cat <<EOF
${PURPLE}
 ███╗   ███╗██╗███╗   ██╗██╗██╗  ██╗██╗   ██╗██████╗ ███████╗
 ████╗ ████║██║████╗  ██║██║██║ ██╔╝██║   ██║██╔══██╗██╔════╝
 ██╔████╔██║██║██╔██╗ ██║██║█████╔╝ ██║   ██║██████╔╝█████╗  
 ██║╚██╔╝██║██║██║╚██╗██║██║██╔═██╗ ██║   ██║██╔══██╗██╔══╝  
 ██║ ╚═╝ ██║██║██║ ╚████║██║██║  ██╗╚██████╔╝██████╔╝███████╗
 ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
                                                               
 Production-Ready Setup Script
 30 Days of Kubernetes - Día 1
${NC}

EOF

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cpus)
                CPUS="$2"
                shift 2
                ;;
            --memory)
                MEMORY="$2"
                shift 2
                ;;
            --driver)
                DRIVER="$2"
                shift 2
                ;;
            --disk-size)
                DISK_SIZE="$2"
                shift 2
                ;;
            --cluster-name)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            --help)
                echo "Uso: $0 [opciones]"
                echo "Opciones:"
                echo "  --cpus NUMBER          Número de CPUs (default: 4)"
                echo "  --memory NUMBER        Memoria en MB (default: 8192)"
                echo "  --driver DRIVER        Driver de virtualización (default: docker)"
                echo "  --disk-size SIZE       Tamaño del disco (default: 50g)"
                echo "  --cluster-name NAME    Nombre del cluster (default: minikube)"
                echo "  --help                 Mostrar esta ayuda"
                exit 0
                ;;
            *)
                print_error "Opción desconocida: $1"
                exit 1
                ;;
        esac
    done
    
    # Ejecutar instalación paso a paso
    if ! check_system_requirements; then
        exit 1
    fi
    
    install_docker
    install_kubectl
    install_minikube
    start_minikube
    install_addons
    setup_additional_tools
    create_examples
    verify_installation
    show_post_install_info
    
    print_success "¡Instalación de Minikube completada exitosamente! 🎉"
    print_info "Reinicia tu terminal para aplicar todos los cambios"
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
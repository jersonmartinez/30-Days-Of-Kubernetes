#!/bin/bash

# ===================================================================
# Kubernetes Overview Demo Script - Día 0
# Demonstración práctica de conceptos fundamentales de Kubernetes
# ===================================================================

set -euo pipefail

# Colors para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
DEMO_NAMESPACE="k8s-demo"
DEMO_IMAGE="nginx:alpine"

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

# Verificar dependencias
check_dependencies() {
    print_header "Verificando Dependencias del Sistema"
    
    local deps=("docker" "kubectl" "curl" "jq")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep está instalado"
        else
            missing_deps+=("$dep")
            print_error "$dep NO está instalado"
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Dependencias faltantes: ${missing_deps[*]}"
        print_info "Instala las dependencias faltantes antes de continuar"
        return 1
    fi
    
    # Verificar conexión a cluster
    if kubectl cluster-info &> /dev/null; then
        print_success "Conexión a cluster Kubernetes establecida"
        kubectl get nodes --no-headers | while read line; do
            echo "   📦 Nodo: $(echo "$line" | awk '{print $1}') - Estado: $(echo "$line" | awk '{print $2}')"
        done
    else
        print_error "No se puede conectar al cluster Kubernetes"
        print_info "Asegúrate de tener kubectl configurado y un cluster ejecutándose"
        return 1
    fi
}

# Demostrar diferencias entre tecnologías de virtualización
demo_virtualization_comparison() {
    print_header "Comparativa: Servidor Físico vs VM vs Contenedor"
    
    # Simular servidor físico
    print_step "1. SERVIDOR FÍSICO - Análisis"
    echo -e "${PURPLE}Características del hardware actual:${NC}"
    
    if [ -f /proc/cpuinfo ]; then
        local cpu_cores=$(nproc)
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        local memory_total=$(free -h | awk '/^Mem:/ {print $2}')
        local memory_available=$(free -h | awk '/^Mem:/ {print $7}')
        
        echo "   🔧 CPU: $cpu_model ($cpu_cores cores)"
        echo "   💾 Memoria Total: $memory_total"
        echo "   🟢 Memoria Disponible: $memory_available"
        echo "   ⏰ Tiempo de inicio típico: 2-5 minutos"
        echo "   🔒 Aislamiento: Físico completo"
        echo "   💰 Costo: Hardware dedicado + mantenimiento"
    fi
    
    sleep 2
    
    # Demostrar VM
    print_step "2. MÁQUINA VIRTUAL - Simulación"
    echo -e "${PURPLE}Características de virtualización completa:${NC}"
    echo "   🖥️  Hipervisor: VMware/KVM/Hyper-V"
    echo "   💻 SO Guest: Linux/Windows independiente"
    echo "   📊 Overhead: 10-20% de recursos"
    echo "   ⏰ Tiempo de inicio: 30-120 segundos"
    echo "   🔒 Aislamiento: Nivel hipervisor"
    echo "   💰 Costo: Licencias + overhead de recursos"
    
    # Simular creación de VM
    echo -e "\n${CYAN}Simulando inicio de VM...${NC}"
    local vm_start_time=$(date +%s)
    for i in {1..10}; do
        echo -n "."
        sleep 0.3
    done
    local vm_end_time=$(date +%s)
    local vm_duration=$((vm_end_time - vm_start_time))
    echo -e " VM iniciada en ${vm_duration}s ✓"
    
    sleep 1
    
    # Demostrar contenedor
    print_step "3. CONTENEDOR - Demostración Real"
    echo -e "${PURPLE}Características de contenedores:${NC}"
    echo "   🐳 Engine: Docker/Containerd/CRI-O"
    echo "   🔄 SO Compartido: Kernel del host"
    echo "   📊 Overhead: 1-3% de recursos"
    echo "   ⏰ Tiempo de inicio: Milisegundos"
    echo "   🔒 Aislamiento: Namespaces + cgroups"
    echo "   💰 Costo: Mínimo overhead"
    
    # Crear contenedor real para demostrar velocidad
    if docker info &> /dev/null; then
        echo -e "\n${CYAN}Creando contenedor real...${NC}"
        local container_start=$(date +%s%N)
        
        # Crear contenedor en background
        local container_id=$(docker run --rm -d --name k8s-demo-container nginx:alpine)
        
        local container_end=$(date +%s%N)
        local duration_ms=$(( (container_end - container_start) / 1000000 ))
        
        print_success "Contenedor creado en ${duration_ms}ms"
        
        # Mostrar información del contenedor
        echo -e "\n${CYAN}Información del contenedor:${NC}"
        docker inspect "$container_id" --format="   📦 ID: {{.Id | slice 0 12}}"
        docker inspect "$container_id" --format="   🖼️  Imagen: {{.Config.Image}}"
        docker inspect "$container_id" --format="   🔄 Estado: {{.State.Status}}"
        docker inspect "$container_id" --format="   💾 Memoria asignada: {{.HostConfig.Memory}}"
        
        # Limpiar
        docker stop "$container_id" &> /dev/null
        print_info "Contenedor eliminado"
    else
        print_warning "Docker no está ejecutándose, simulando tiempo de inicio..."
        echo "   ⚡ Contenedor creado en ~200ms"
    fi
    
    # Tabla comparativa
    echo -e "\n${PURPLE}📊 TABLA COMPARATIVA:${NC}"
    printf "%-15s %-15s %-15s %-15s\n" "Métrica" "Servidor Físico" "Máquina Virtual" "Contenedor"
    printf "%-15s %-15s %-15s %-15s\n" "Tiempo Inicio" "2-5 minutos" "30-120 segundos" "< 1 segundo"
    printf "%-15s %-15s %-15s %-15s\n" "Overhead" "0%" "10-20%" "1-3%"
    printf "%-15s %-15s %-15s %-15s\n" "Densidad" "1 app/server" "5-10 VMs/server" "50-100 contenedores"
    printf "%-15s %-15s %-15s %-15s\n" "Aislamiento" "Completo" "Fuerte" "Proceso"
    printf "%-15s %-15s %-15s %-15s\n" "Portabilidad" "Ninguna" "Media" "Alta"
}

# Demostrar conceptos básicos de Kubernetes
demo_kubernetes_concepts() {
    print_header "Conceptos Fundamentales de Kubernetes"
    
    # Crear namespace para demos
    print_step "Creando namespace de demostración"
    if kubectl create namespace "$DEMO_NAMESPACE" &> /dev/null; then
        print_success "Namespace '$DEMO_NAMESPACE' creado"
    else
        print_info "Namespace '$DEMO_NAMESPACE' ya existe"
    fi
    
    # 1. Pod - La unidad básica
    print_step "1. POD - La unidad básica de despliegue"
    echo -e "${PURPLE}¿Qué es un Pod?${NC}"
    echo "   • Wrapper alrededor de uno o más contenedores"
    echo "   • Comparten red y almacenamiento"
    echo "   • Mortal y efímero"
    echo "   • Unidad mínima de escalamiento"
    
    # Crear un pod simple
    cat > /tmp/demo-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
  namespace: $DEMO_NAMESPACE
  labels:
    app: demo
    tier: frontend
spec:
  containers:
  - name: nginx
    image: $DEMO_IMAGE
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
    
    print_info "Aplicando Pod..."
    kubectl apply -f /tmp/demo-pod.yaml
    
    # Esperar a que el pod esté listo
    echo -n "   Esperando que el Pod esté listo"
    while [[ $(kubectl get pod demo-pod -n "$DEMO_NAMESPACE" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
        echo -n "."
        sleep 1
    done
    echo ""
    
    print_success "Pod creado y ejecutándose"
    kubectl get pod demo-pod -n "$DEMO_NAMESPACE" -o wide
    
    # 2. Service - Exposición de red
    print_step "2. SERVICE - Abstracción de red"
    echo -e "${PURPLE}¿Qué es un Service?${NC}"
    echo "   • Abstracción que define acceso a Pods"
    echo "   • IP estable para conjunto de Pods"
    echo "   • Load balancing automático"
    echo "   • Service discovery nativo"
    
    # Crear service
    cat > /tmp/demo-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  namespace: $DEMO_NAMESPACE
spec:
  selector:
    app: demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    
    kubectl apply -f /tmp/demo-service.yaml
    print_success "Service creado"
    kubectl get service demo-service -n "$DEMO_NAMESPACE"
    
    # 3. Deployment - Gestión de Pods
    print_step "3. DEPLOYMENT - Gestión declarativa de Pods"
    echo -e "${PURPLE}¿Qué es un Deployment?${NC}"
    echo "   • Gestiona ReplicaSets y Pods"
    echo "   • Rollouts y rollbacks automáticos"
    echo "   • Escalamiento horizontal"
    echo "   • Self-healing automático"
    
    # Primero eliminar el pod individual
    kubectl delete pod demo-pod -n "$DEMO_NAMESPACE" --wait=false
    
    # Crear deployment
    cat > /tmp/demo-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deployment
  namespace: $DEMO_NAMESPACE
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: $DEMO_IMAGE
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF
    
    kubectl apply -f /tmp/demo-deployment.yaml
    
    # Esperar a que el deployment esté listo
    echo -n "   Esperando que el Deployment esté listo"
    kubectl wait --for=condition=available --timeout=60s deployment/demo-deployment -n "$DEMO_NAMESPACE"
    echo ""
    
    print_success "Deployment creado con 3 réplicas"
    kubectl get deployment demo-deployment -n "$DEMO_NAMESPACE"
    kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo
}

# Demostrar self-healing
demo_self_healing() {
    print_header "Demostración de Self-Healing"
    
    print_step "Estado inicial del Deployment"
    kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers
    
    print_step "Simulando falla de Pod..."
    # Obtener un pod aleatorio
    local pod_to_delete=$(kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers | head -1 | awk '{print $1}')
    
    if [ -n "$pod_to_delete" ]; then
        echo "   🎯 Eliminando pod: $pod_to_delete"
        kubectl delete pod "$pod_to_delete" -n "$DEMO_NAMESPACE" --grace-period=0 --force
        
        print_info "Kubernetes detectará la falla y creará un nuevo Pod automáticamente..."
        sleep 3
        
        echo -n "   Esperando recuperación automática"
        local count=0
        while [ "$count" -lt 30 ]; do
            local ready_pods=$(kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers | grep "Running" | wc -l)
            if [ "$ready_pods" -eq 3 ]; then
                echo ""
                break
            fi
            echo -n "."
            sleep 2
            ((count++))
        done
        
        print_success "Self-healing completado - 3 Pods ejecutándose nuevamente"
        kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers
    fi
}

# Demostrar escalamiento
demo_scaling() {
    print_header "Demostración de Escalamiento"
    
    print_step "Escalamiento horizontal (más réplicas)"
    echo "   📈 Escalando de 3 a 5 réplicas..."
    kubectl scale deployment demo-deployment --replicas=5 -n "$DEMO_NAMESPACE"
    
    echo -n "   Esperando que las nuevas réplicas estén listas"
    kubectl wait --for=condition=available --timeout=60s deployment/demo-deployment -n "$DEMO_NAMESPACE"
    echo ""
    
    print_success "Escalamiento completado"
    kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers | nl
    
    print_step "Reduciendo escala de vuelta a 3 réplicas"
    kubectl scale deployment demo-deployment --replicas=3 -n "$DEMO_NAMESPACE"
    
    echo -n "   Esperando terminación de Pods extra"
    sleep 5
    echo ""
    
    print_success "Escala reducida a 3 réplicas"
    kubectl get pods -n "$DEMO_NAMESPACE" -l app=demo --no-headers
}

# Demostrar rolling updates
demo_rolling_update() {
    print_header "Demostración de Rolling Update"
    
    print_step "Estado actual del Deployment"
    kubectl get deployment demo-deployment -n "$DEMO_NAMESPACE" -o wide
    
    print_step "Actualizando imagen a nginx:1.21"
    kubectl set image deployment/demo-deployment nginx=nginx:1.21 -n "$DEMO_NAMESPACE"
    
    print_info "Observando el rolling update en progreso..."
    echo -n "   Progreso del rollout"
    
    # Mostrar progreso del rollout
    local rollout_status=""
    while [[ "$rollout_status" != "deployment \"demo-deployment\" successfully rolled out" ]]; do
        rollout_status=$(kubectl rollout status deployment/demo-deployment -n "$DEMO_NAMESPACE" 2>&1 | tail -1)
        echo -n "."
        sleep 2
    done
    echo ""
    
    print_success "Rolling update completado"
    kubectl get deployment demo-deployment -n "$DEMO_NAMESPACE" -o wide
    
    # Mostrar historial de rollout
    print_step "Historial de rollouts"
    kubectl rollout history deployment/demo-deployment -n "$DEMO_NAMESPACE"
}

# Demostrar configuración y secretos
demo_config_secrets() {
    print_header "Demostración de ConfigMaps y Secrets"
    
    # ConfigMap
    print_step "Creando ConfigMap"
    cat > /tmp/demo-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
  namespace: $DEMO_NAMESPACE
data:
  database_url: "postgres://demo-db:5432/app"
  app_mode: "production"
  max_connections: "100"
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
EOF
    
    kubectl apply -f /tmp/demo-configmap.yaml
    print_success "ConfigMap creado"
    
    # Secret
    print_step "Creando Secret"
    kubectl create secret generic demo-secret \
        --from-literal=db-password="super-secret-password" \
        --from-literal=api-key="abc123xyz789" \
        -n "$DEMO_NAMESPACE"
    
    print_success "Secret creado"
    
    # Mostrar como se ven (sin revelar secrets)
    print_info "ConfigMap contenido:"
    kubectl get configmap demo-config -n "$DEMO_NAMESPACE" -o yaml | grep -A 10 "data:"
    
    print_info "Secret (valores enmascarados por seguridad):"
    kubectl get secret demo-secret -n "$DEMO_NAMESPACE" -o yaml | grep -A 5 "data:"
}

# Cleanup función
cleanup_demo() {
    print_header "Limpieza de Recursos de Demostración"
    
    print_step "Eliminando namespace de demostración..."
    kubectl delete namespace "$DEMO_NAMESPACE" --ignore-not-found=true &
    
    # Limpiar archivos temporales
    rm -f /tmp/demo-*.yaml
    
    # Esperar un poco para que la eliminación comience
    sleep 3
    
    print_success "Limpieza iniciada (se completará en background)"
    print_info "Usa 'kubectl get namespace' para verificar que el namespace se haya eliminado"
}

# Función principal
main() {
    clear
    
    cat <<EOF
${PURPLE}
 ██╗  ██╗ █████╗ ███████╗
 ██║ ██╔╝██╔══██╗██╔════╝
 █████╔╝ ╚█████╔╝███████╗
 ██╔═██╗ ██╔══██╗╚════██║
 ██║  ██╗╚█████╔╝███████║
 ╚═╝  ╚═╝ ╚════╝ ╚══════╝
                          
 Kubernetes Overview Demo
 30 Days of Kubernetes - Día 0
${NC}

EOF

    if ! check_dependencies; then
        exit 1
    fi
    
    demo_virtualization_comparison
    demo_kubernetes_concepts
    demo_self_healing
    demo_scaling
    demo_rolling_update
    demo_config_secrets
    
    print_header "¡Demo Completada Exitosamente!"
    
    print_step "Resumen de lo que has aprendido:"
    echo "   🔍 Diferencias entre servidores físicos, VMs y contenedores"
    echo "   📦 Conceptos básicos: Pods, Services, Deployments"
    echo "   🔄 Self-healing automático de Kubernetes"
    echo "   📈 Escalamiento horizontal dinámico"
    echo "   🚀 Rolling updates sin downtime"
    echo "   ⚙️  Gestión de configuración con ConfigMaps y Secrets"
    
    print_step "Próximos pasos:"
    echo "   1. Explorar kubectl con 'kubectl --help'"
    echo "   2. Revisar los manifiestos YAML generados en /tmp/"
    echo "   3. Continuar con el Día 1: Instalación y configuración avanzada"
    echo "   4. Experimentar con tus propias aplicaciones"
    
    echo ""
    read -p "$(echo -e ${YELLOW}¿Deseas limpiar los recursos de demostración? [y/N]:${NC} )" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_demo
    else
        print_info "Recursos mantenidos en namespace '$DEMO_NAMESPACE'"
        print_info "Para limpiar manualmente: kubectl delete namespace $DEMO_NAMESPACE"
    fi
    
    print_info "Para más información: https://kubernetes.io/docs/"
    echo -e "\n${GREEN}¡Felicidades! Has completado la demostración de Kubernetes Día 0 🎉${NC}"
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
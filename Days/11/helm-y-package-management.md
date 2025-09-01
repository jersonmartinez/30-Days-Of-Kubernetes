# Helm y Package Management

<div align="center">

[![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

**Gestión de **paquetes** en Kubernetes con Helm** 🚀
*Release management y automatización de despliegues*

</div>

---

## 🎯 Introducción

Helm es el **gestor de paquetes oficial de Kubernetes**, que simplifica el despliegue y gestión de aplicaciones complejas. En este día aprenderemos a instalar Helm en WSL con Debian y dominar sus comandos esenciales para implementar **release management** en entornos DevOps.

### 🌟 ¿Por qué Helm?

- 📦 **Paquetes reutilizables**: Charts preconstruidos para aplicaciones populares
- 🔄 **Versionado**: Control de versiones de tus despliegues
- 🚀 **Automatización**: Despliegues consistentes y repetibles
- 🔧 **Personalización**: Valores override para diferentes entornos
- 📊 **Gestión**: Upgrade, rollback y eliminación sencilla

---

## 🛠️ Instalación de Helm en WSL con Debian

### 📋 Prerrequisitos

- WSL con Debian (instalado en Día 01)
- Kubernetes corriendo (minikube o cluster local)
- Conexión a internet

### 🚀 Pasos de Instalación

#### 1. Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Instalar dependencias

```bash
sudo apt install -y curl wget gnupg2 software-properties-common apt-transport-https
```

#### 3. Instalar Helm usando el script oficial

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### 4. Verificar la instalación

```bash
helm version
```

Deberías ver algo como:
```
version.BuildInfo{Version:"v3.14.0", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.21.5"}
```

#### 5. Instalar bash completion (opcional pero recomendado)

```bash
# Crear directorio si no existe
sudo mkdir -p /etc/bash_completion.d

# Instalar completion
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
source ~/.bashrc
```

---

## 📚 Comandos Básicos de Helm

### 🔍 Gestión de Repositorios

#### Agregar repositorio oficial de Bitnami

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

#### Listar repositorios

```bash
helm repo list
```

#### Actualizar repositorios

```bash
helm repo update
```

#### Buscar charts

```bash
helm search repo nginx
```

### 📦 Gestión de Charts

#### Instalar una aplicación

```bash
helm install my-nginx bitnami/nginx
```

#### Listar releases instalados

```bash
helm list
```

#### Ver estado de un release

```bash
helm status my-nginx
```

#### Obtener información detallada

```bash
helm get all my-nginx
```

#### Ver valores usados

```bash
helm get values my-nginx
```

#### Ver manifest generado

```bash
helm get manifest my-nginx
```

### 🔄 Gestión del Ciclo de Vida

#### Actualizar un release

```bash
helm upgrade my-nginx bitnami/nginx --set service.type=LoadBalancer
```

#### Rollback a versión anterior

```bash
helm rollback my-nginx 1
```

#### Desinstalar un release

```bash
helm uninstall my-nginx
```

---

## 🎪 Ejemplos Prácticos DevOps

### 🌐 Desplegar WordPress completo

```bash
# Agregar repo de Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Instalar WordPress con MariaDB
helm install my-wordpress bitnami/wordpress \
  --set wordpressUsername=admin \
  --set wordpressPassword=password \
  --set mariadb.auth.rootPassword=secretpassword
```

### 📊 Desplegar Prometheus + Grafana

```bash
# Agregar repo de Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Instalar stack de monitoreo
helm install monitoring prometheus-community/kube-prometheus-stack
```

### 🔧 Personalización con values.yaml

Crear archivo `values.yaml`:

```yaml
replicaCount: 3
image:
  tag: "latest"
service:
  type: LoadBalancer
  port: 80
```

Instalar con valores personalizados:

```bash
helm install my-app ./my-chart -f values.yaml
```

### 🚀 Ejemplo Práctico: Desplegando una App Java

Basado en experiencias reales, aquí tienes un ejemplo completo de cómo desplegar una aplicación Java usando YAML y comandos kubectl, con integración a Helm. Este ejemplo incluye troubleshooting para problemas comunes como nombres en uso o recursos residuales.

#### 📄 Archivo k8s.yaml de Ejemplo

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-java
  namespace: hello
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-java
  template:
    metadata:
      labels:
        app: hello-java
    spec:
      containers:
      - name: hello-java
        image: java-hello-world # ej: us-docker.pkg.dev/myproj/hello-repo/java-hello-world:1.0.0
        ports:
        - containerPort: 8085
        readinessProbe:
          httpGet:
            path: /
            port: 8085
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 8085
          initialDelaySeconds: 15
          periodSeconds: 20
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-java-svc
  namespace: hello
spec:
  selector:
    app: hello-java
  ports:
  - name: http
    port: 80
    targetPort: 8085
  type: ClusterIP
```

#### 🛠️ Pipeline de Despliegue

```bash
# Aplicar recursos
kubectl apply -f k8s.yaml

# Verificar en namespace "hello"
kubectl -n hello get pods
kubectl -n hello get svc
kubectl -n hello rollout status deployment/hello-java
kubectl -n hello logs deploy/hello-java
```

#### 🔍 Explicación de Recursos

- **Namespace**: Aísla la app en "hello" (explica el `-n hello`).
- **Deployment**: Crea 2 pods con probes de health y límites de recursos.
- **Service**: Expone la app internamente en puerto 80.

#### 🐛 Troubleshooting Común

##### ❌ Error: "cannot re-use a name that is still in use"
- **Causa**: Release de Helm o recursos kubectl previos con el mismo nombre.
- **Solución**:
  ```bash
  # Ver releases activos
  helm list
  
  # Desinstalar si existe
  helm uninstall my-nginx
  
  # Limpiar recursos residuales
  kubectl delete deployment nginx
  kubectl delete service my-nginx
  kubectl delete pod nginx  # Si existe
  
  # Reintentar
  helm install my-nginx bitnami/nginx
  ```

##### ❌ Pods en estado Pending o CrashLoopBackOff
- **Verificar logs**:
  ```bash
  kubectl -n hello logs deploy/hello-java
  ```
- **Describir para más detalles**:
  ```bash
  kubectl -n hello describe deployment hello-java
  ```

##### ❌ Service no accesible
- **Port-forwarding para testing**:
  ```bash
  kubectl -n hello port-forward svc/hello-java-svc 8080:80
  # Accede en http://localhost:8080
  ```

#### 🔄 Integración con Helm

Para convertir este YAML a un chart de Helm:

```bash
# Crear chart básico
helm create hello-java-chart

# Copiar recursos a templates/
# Editar values.yaml para personalizar imagen, réplicas, etc.

# Instalar
helm install hello-release ./hello-java-chart -n hello
```

---

## 🏗️ Creando Tu Primer Chart

### 📁 Estructura básica

```bash
mkdir my-chart
cd my-chart
helm create my-app
```

### 📝 Archivos importantes

- `Chart.yaml`: Metadatos del chart
- `values.yaml`: Valores por defecto
- `templates/`: Plantillas de Kubernetes
- `charts/`: Dependencias

### 🚀 Desplegar tu chart

```bash
helm install my-release ./my-chart
```

---

## 🔧 Troubleshooting Común

### ❌ Error: "Error: Kubernetes cluster unreachable"

```bash
# Verificar contexto de kubectl
kubectl config current-context

# Verificar cluster
kubectl cluster-info
```

### ❌ Error: "Error: release my-release failed: ..."

```bash
# Ver logs detallados
helm install my-release ./chart --debug --dry-run

# Ver estado del release
helm status my-release
```

### ❌ Error: "Error: repo ... not found"

```bash
# Actualizar repositorios
helm repo update

# Ver repositorios
helm repo list
```

---

## 📈 Mejores Prácticas DevOps

### 🔒 **Security**
- Usar helm secrets para datos sensibles
- Validar charts con helm lint
- Firmar charts con helm sign

### 🚀 **CI/CD Integration**
```yaml
# Ejemplo GitHub Actions
- name: Deploy with Helm
  run: |
    helm upgrade --install my-app ./chart \
      --namespace production \
      --create-namespace \
      --wait
```

### 📊 **Versioning**
- Usar semantic versioning (v1.2.3)
- Mantener historial de releases
- Documentar cambios en Chart.yaml

---

## 📜 Scripts de Ejemplo

Para facilitar el aprendizaje práctico, hemos creado scripts automatizados que puedes ejecutar directamente. Todos los scripts están disponibles en el directorio [`scripts/`](./scripts/) de este día.

### 🛠️ Script de Instalación de Helm

```bash
#!/bin/bash

# Script para instalar Helm en WSL con Debian
# Ejecutar con: bash scripts/install-helm.sh

echo "🚀 Instalando Helm en WSL con Debian..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
echo "🔧 Instalando dependencias..."
sudo apt install -y curl wget gnupg2 software-properties-common apt-transport-https

# Instalar Helm usando script oficial
echo "⚙️ Instalando Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar instalación
echo "✅ Verificando instalación..."
helm version

# Instalar bash completion
echo "🎯 Configurando autocompletado..."
sudo mkdir -p /etc/bash_completion.d
helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null

echo "🎉 ¡Helm instalado exitosamente!"
echo "Recarga tu shell con: source ~/.bashrc"
```

**Para ejecutar:**
```bash
chmod +x scripts/install-helm.sh
./scripts/install-helm.sh
```

### 🎪 Script de Demostración Básica

```bash
#!/bin/bash

# Script de demostración de comandos básicos de Helm
# Ejecutar con: bash scripts/helm-demo.sh

echo "🎪 Demostración de comandos básicos de Helm"

# Ver versión
echo "📋 Versión de Helm:"
helm version --short

# Agregar repositorio
echo "📚 Agregando repositorio Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami

# Listar repositorios
echo "📋 Repositorios configurados:"
helm repo list

# Actualizar repositorios
echo "🔄 Actualizando repositorios..."
helm repo update

# Buscar charts
echo "🔍 Buscando charts de nginx:"
helm search repo nginx | head -10

# Instalar aplicación de ejemplo
echo "📦 Instalando nginx de ejemplo..."
helm install demo-nginx bitnami/nginx --set service.type=ClusterIP

# Esperar un momento
sleep 5

# Listar releases
echo "📋 Releases instalados:"
helm list

# Ver estado
echo "📊 Estado del release:"
helm status demo-nginx

# Obtener valores
echo "⚙️ Valores usados:"
helm get values demo-nginx

# Desinstalar
echo "🗑️ Desinstalando demo..."
helm uninstall demo-nginx

echo "🎉 ¡Demostración completada!"
```

**Para ejecutar:**
```bash
chmod +x scripts/helm-demo.sh
./scripts/helm-demo.sh
```

### 🌐 Script de Despliegue de WordPress

```bash
#!/bin/bash

# Script para desplegar WordPress completo con Helm
# Ejecutar con: bash scripts/deploy-wordpress.sh

echo "🌐 Desplegando WordPress con Helm..."

# Variables de configuración
RELEASE_NAME="my-wordpress"
NAMESPACE="wordpress"

# Crear namespace si no existe
echo "📁 Creando namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Agregar repositorio Bitnami
echo "📚 Agregando repositorio Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Instalar WordPress
echo "📦 Instalando WordPress..."
helm install $RELEASE_NAME bitnami/wordpress \
  --namespace $NAMESPACE \
  --set wordpressUsername=admin \
  --set wordpressPassword=securepassword123 \
  --set mariadb.auth.rootPassword=rootpassword123 \
  --set service.type=LoadBalancer \
  --wait

# Esperar a que esté listo
echo "⏳ Esperando que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE --timeout=300s

# Obtener información de acceso
echo "🎯 Información de acceso:"
echo "Usuario: admin"
echo "Contraseña: securepassword123"
echo ""
echo "URL del servicio:"
kubectl get svc $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo "Para acceder localmente:"
echo "kubectl port-forward svc/$RELEASE_NAME 8080:80 -n $NAMESPACE"
echo "Luego visita: http://localhost:8080"

# Mostrar estado
echo "📊 Estado del despliegue:"
helm status $RELEASE_NAME -n $NAMESPACE

echo "🎉 ¡WordPress desplegado exitosamente!"
```

**Para ejecutar:**
```bash
chmod +x scripts/deploy-wordpress.sh
./scripts/deploy-wordpress.sh
```

### 💡 Consejos para los Scripts

- **Permisos**: Asegúrate de dar permisos de ejecución con `chmod +x`
- **Personalización**: Modifica las variables según tus necesidades
- **Debugging**: Agrega `--debug` a comandos Helm para más información
- **Cleanup**: Usa `helm uninstall` para limpiar releases de prueba

---

## 🎯 Próximos Pasos

- **Día 12**: ArgoCD y GitOps workflow
- **Día 13**: Monitoring con Prometheus/Grafana
- **Proyecto**: Crear pipeline CI/CD con Helm

### 📚 Recursos Adicionales

- [Documentación Oficial Helm](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/) - Repositorio de charts
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

---

<div align="center">

### 💡 **Recuerda**: Helm es tu aliado para releases consistentes y automatizados

**¿Listo para el siguiente nivel con GitOps?** → [Día 12](../12/)

</div>
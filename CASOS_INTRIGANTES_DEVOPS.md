# 🧠 Casos Intrigantes y Proyectos DevOps con Kubernetes

## 🎭 Filosofía DevOps en Kubernetes

### Los 5 Pilares DevOps aplicados a K8s

1. **🤝 Colaboración**: Infrastructure as Code compartido entre Dev y Ops
2. **🔄 Automatización**: CI/CD pipelines nativos en Kubernetes  
3. **📊 Medición**: Observabilidad completa (logs, métricas, trazas)
4. **📈 Mejora Continua**: Iteración basada en feedback de production
5. **⚡ Velocidad**: Deploy frecuentes con rollback automático

---

## 🔥 Casos Intrigantes para Pensar

### Caso 1: La Catástrofe del Viernes Negro 🛒💥

**Contexto**: E-commerce con 50M usuarios. Durante Black Friday, el tráfico sube de 1K RPS a 15K RPS en 30 minutos.

**Lo que salió mal**:
- Database se saturó (conexiones pool agotado)
- Imágenes de CDN colapsaron 
- Session storage (Redis) se quedó sin memoria
- Pagos empezaron a fallar por timeouts

**💭 Pregunta Intrigante**: *Si solo puedes implementar 3 cambios antes del próximo Black Friday, ¿cuáles serían y por qué?*

<details>
<summary>🔍 Análisis de Soluciones</summary>

**Solución Subóptima** (reactiva):
```yaml
# Solo escalar réplicas - NO resuelve el problema raíz
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 100  # Esto NO solucionará DB bottleneck
```

**Solución Óptima** (preventiva):
```yaml
# 1. HPA con custom metrics (DB connections)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-app
  minReplicas: 10
  maxReplicas: 200
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: db_connections_per_pod
      target:
        type: AverageValue
        averageValue: "30"
---
# 2. Circuit Breaker Pattern
apiVersion: v1
kind: ConfigMap
metadata:
  name: circuit-breaker-config
data:
  config.yaml: |
    circuitBreaker:
      failureThreshold: 5
      recoveryTimeout: 30s
      fallbackResponse: |
        {
          "message": "Service temporarily unavailable. Please try again.",
          "retryAfter": 30
        }
---
# 3. Redis Cluster para session storage
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  serviceName: redis-cluster
  replicas: 6
  template:
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
```

**¿Por qué esta solución?**:
1. **HPA con métricas custom** previene saturación antes que ocurra
2. **Circuit breakers** protegen dependencias downstream
3. **Redis cluster** elimina el single point of failure

</details>

### Caso 2: El Misterio de la Latencia Fantasma 👻

**Contexto**: Microservicio de autenticación que súbitamente tiene latencia P99 de 2 segundos cuando antes era 50ms.

**Síntomas observados**:
- CPU y memoria normales
- Database queries son rápidas  
- Network no muestra congestión
- Solo ocurre en horarios específicos (9AM-11AM)

**💭 Pregunta Intrigante**: *¿Qué herramientas usarías para diagnosticar este problema? ¿Cuáles son las 5 hipótesis más probables?*

<details>
<summary>🔍 Metodología de Debugging</summary>

**Herramientas de Diagnóstico**:
```bash
# 1. Analizar distributed tracing
kubectl port-forward svc/jaeger-query 16686:16686
# Buscar spans con alta latencia

# 2. Revisar métricas detalladas
kubectl port-forward svc/prometheus 9090:9090
# Query: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

# 3. Analizar garbage collection
kubectl logs -f deployment/auth-service | grep -i "gc"

# 4. Revisar resource limits y requests
kubectl describe pod auth-service-xxx | grep -A 10 "Limits\|Requests"

# 5. Verificar DNS resolution
kubectl exec -it auth-service-xxx -- nslookup database-service
```

**Las 5 Hipótesis Más Probables**:

1. **GC Pauses**: JVM/Go GC bloqueando threads
2. **DNS Resolution**: CoreDNS saturado durante peak hours  
3. **Connection Pool Starvation**: Pool size insuficiente
4. **CPU Throttling**: Limits muy bajos causando throttling
5. **Cold Start**: Pods siendo reciclados y warming up

**Solución Encontrada** (caso real):
```yaml
# El problema era DNS resolution!
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 300  # Aumentar cache TTL
        loop
        reload
        loadbalance
    }
---
# Y optimizar el deployment
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      dnsPolicy: ClusterFirst
      dnsConfig:
        options:
        - name: ndots
          value: "2"  # Reducir ndots para menos queries DNS
        - name: edns0
```

</details>

### Caso 3: El Deployment que Nunca Termina 🔄

**Contexto**: Deployment stuck en rolling update. Nuevos pods en estado "Running" pero health checks fallan.

**Lo extraño**:
- Aplicación funciona perfectamente en local
- Tests pasan en CI/CD
- Port-forward al pod funciona correctamente
- Logs no muestran errores

**💭 Pregunta Intrigante**: *¿Qué diferencias entre ambiente local y Kubernetes podrían causar esto? Diseña una estrategia de debugging sistemática.*

<details>
<summary>🔍 Estrategia de Debugging Sistemática</summary>

**Checklist de Debugging**:

```bash
# 1. Verificar health check configuration
kubectl describe deployment problematic-app
kubectl get pods -o yaml | grep -A 10 "readinessProbe\|livenessProbe"

# 2. Revisar logs detalladamente  
kubectl logs deployment/problematic-app --previous
kubectl logs deployment/problematic-app -c init-container

# 3. Inspeccionar network policies
kubectl get networkpolicy
kubectl describe networkpolicy default-deny

# 4. Verificar service endpoints
kubectl get endpoints problematic-app-service
kubectl describe service problematic-app-service

# 5. Analizar diferencias de configuración
kubectl exec -it problematic-app-xxx -- env | sort
kubectl exec -it problematic-app-xxx -- cat /etc/resolv.conf
```

**Causa Raíz Común** (encontrada en 70% de casos similares):
```yaml
# El health check apuntaba a localhost en lugar del pod IP
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:v2
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
            host: "127.0.0.1"  # ❌ PROBLEMA: localhost no funciona con service
          initialDelaySeconds: 10
          periodSeconds: 5
        # ✅ SOLUCIÓN: Quitar 'host' o usar pod IP
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
            # Sin 'host' usa la IP del pod automáticamente
```

**Solución Completa**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: problematic-app
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Cero downtime
  template:
    spec:
      containers:
      - name: app
        image: myapp:v2
        ports:
        - containerPort: 8080
        # Health checks apropiados
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        # Resource limits realistas
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi" 
            cpu: "500m"
```

</details>

---

## 🚀 Proyectos Prácticos DevOps

### Proyecto 1: E-commerce Resiliente 🛍️

**Objetivo**: Construir un e-commerce que soporte 10K usuarios concurrentes con 99.9% uptime.

**Arquitectura Objetivo**:
```
Frontend (React) → API Gateway → Microservicios → Databases
     ↓                 ↓              ↓            ↓
   CDN           Load Balancer    Service Mesh   Persistent Storage
```

**Requisitos DevOps**:
- GitOps workflow con ArgoCD
- Blue-green deployments
- Chaos engineering con Litmus
- Observabilidad completa
- Auto-scaling basado en business metrics

**🤔 Pregunta Reflexiva**: *¿Cómo implementarías feature flags para testear nuevas funcionalidades con solo 5% de usuarios?*

### Proyecto 2: Plataforma de Streaming 📺

**Desafío**: Netflix-like platform que escale automáticamente según la demanda.

**Componentes Críticos**:
- Video transcoding pipeline
- Content delivery network
- User recommendation engine  
- Real-time analytics
- Payment processing

**Métricas de Éxito**:
- Latencia < 100ms para inicio de video
- Escalado automático en < 30 segundos
- Costo optimizado por viewer
- Zero data loss en payment processing

**🤔 Pregunta Reflexiva**: *¿Qué estrategia usarías para deployar transcoding jobs sin afectar la experiencia de usuarios actuales?*

### Proyecto 3: FinTech Multi-Región 🏦

**Complejidad**: Aplicación financiera con compliance regulatorio en múltiples países.

**Desafíos Únicos**:
- Datos deben residir en región específica
- Auditoría inmutable de todas las transacciones
- Disaster recovery en < 2 minutos
- Zero-trust security model
- Real-time fraud detection

**🤔 Pregunta Reflexiva**: *¿Cómo implementarías un sistema de disaster recovery que cumpla con GDPR, SOX y PCI DSS simultáneamente?*

---

## 🎯 Casos de Optimización

### Optimización 1: Reducir Costos en 50% 💰

**Situación**: Startup gastando $15K/mes en AWS EKS necesita reducir costos dramáticamente.

**Datos Actuales**:
- 50 microservicios
- Promedio 3 réplicas por servicio
- Utilización CPU promedio: 15%
- Utilización memoria promedio: 30%

**💭 Pregunta Intrigante**: *¿Qué cambios implementarías? Prioriza por impacto vs esfuerzo.*

<details>
<summary>🔍 Estrategia de Optimización</summary>

**Análisis de Quick Wins**:

```yaml
# 1. Vertical Pod Autoscaling (VPA) para right-sizing
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: microservice-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: microservice
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: app
      maxAllowed:
        cpu: 1
        memory: 2Gi
      minAllowed:
        cpu: 100m
        memory: 128Mi
```

**Plan de Optimización (50% reducción)**:

1. **Immediate (Semana 1)**:
   - Implementar VPA en modo Auto
   - Usar Spot Instances para workloads tolerantes a fallas
   - Combinar microservicios de baja utilización

2. **Short-term (Mes 1)**:
   - Cluster autoscaling agresivo  
   - Horizontal Pod Autoscaling con métricas custom
   - Migrar a ARM instances (Graviton)

3. **Long-term (Mes 3)**:
   - Consolidar servicios similares
   - Implementar service mesh para optimizar networking
   - Usar Reserved Instances para baseline workload

**Impacto Esperado**:
- VPA: 30% reducción en recursos
- Spot Instances: 60% reducción en costo compute
- ARM Migration: 20% adicional de ahorro
- **Total: 52% reducción** ($15K → $7.2K/mes)

</details>

### Optimización 2: Acelerar Deployments 10x ⚡

**Problema**: Pipeline de deployment toma 45 minutos. Objetivo: reducir a < 5 minutos.

**Pipeline Actual**:
```
Build (15min) → Test (20min) → Security Scan (8min) → Deploy (2min)
```

**🤔 Pregunta Intrigante**: *¿Qué técnicas aplicarías para paralelizar y optimizar cada etapa?*

<details>
<summary>🔍 Pipeline Optimizado</summary>

**Estrategia de Paralelización**:

```yaml
# GitLab CI optimizado
stages:
  - prepare
  - parallel-build-test
  - security-deploy

# Stage 1: Preparación (30 segundos)
prepare-cache:
  stage: prepare
  script:
    - docker build --target dependencies --cache-from $CI_REGISTRY_IMAGE:deps .
    - docker push $CI_REGISTRY_IMAGE:deps

# Stage 2: Build + Test en paralelo (5 minutos)
build:
  stage: parallel-build-test
  parallel: 3
  script:
    - docker build --cache-from $CI_REGISTRY_IMAGE:deps .
    
unit-tests:
  stage: parallel-build-test
  script:
    - make test-unit

integration-tests:
  stage: parallel-build-test
  script:
    - make test-integration
    
security-scan:
  stage: parallel-build-test
  script:
    - trivy image $IMAGE_TAG

# Stage 3: Deploy progresivo (2 minutos)
deploy-canary:
  stage: security-deploy
  script:
    - kubectl set image deployment/app app=$IMAGE_TAG
    - kubectl patch deployment app -p '{"spec":{"replicas":1}}'
    - ./scripts/health-check.sh
    - kubectl scale deployment app --replicas=10
```

**Optimizaciones Clave**:
1. **Build Cache**: Multi-stage Dockerfile con cache de dependencias
2. **Test Paralelos**: Ejecutar unit/integration/security en paralelo
3. **Canary Deployment**: Deploy progresivo con health checks
4. **Resource Optimization**: Usar builders con más CPU/memoria

**Resultado**: 45 min → 4.5 min (90% mejora)

</details>

---

## 🔬 Laboratorios de Troubleshooting

### Lab 1: El Pod Zombie 🧟

**Síntomas**: Pod aparece como "Running" pero no responde a requests.

**Setup del Lab**:
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: zombie-pod
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
    # Bug oculto: proceso principal termina pero container sigue "Running"
    command: ["/bin/sh"]
    args: ["-c", "nginx & sleep 10 && kill %1 && sleep 3600"]
EOF
```

**Tu misión**: Descubrir por qué el pod no responde y solucionarlo.

### Lab 2: El Network Policy Fantasma 👻

**Síntomas**: Comunicación entre pods falla intermitentemente.

**Setup del Lab**:
```yaml
# Network policy con regla confusa
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mystery-policy
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
  egress:
  - to: []  # ¿Qué significa esto?
```

**Tu misión**: Entender por qué algunos requests fallan y otros no.

---

## 🏆 Desafíos de Arquitectura

### Desafío 1: Multi-Tenant SaaS

**Contexto**: Diseñar una plataforma SaaS donde cada tenant tiene:
- Aislamiento completo de datos
- SLA diferenciados por plan (free, pro, enterprise)
- Facturación basada en usage real
- Compliance específico por industry

**🤔 Pregunta Reflexiva**: *¿Usarías namespaces, clusters separados, o una combinación? ¿Cómo manejarías el shared infrastructure?*

### Desafío 2: IoT Platform a Escala

**Contexto**: 1 millón de dispositivos IoT enviando datos cada 30 segundos.

**Requisitos**:
- Latencia < 100ms para comandos críticos
- Almacenamiento de 1 año de datos históricos
- Real-time analytics y alerting
- Edge computing para reducir latencia

**🤔 Pregunta Reflexiva**: *¿Cómo distribuirías la carga entre cloud y edge? ¿Qué estrategia de partitioning usarías para los datos?*

---

## 📊 Métricas de Éxito DevOps

### DORA Metrics en Kubernetes

1. **Lead Time**: Tiempo desde commit hasta producción
2. **Deployment Frequency**: Cuántas veces deployeas por día
3. **Mean Time to Recovery**: Tiempo para resolver incidents
4. **Change Failure Rate**: % de deployments que causan failures

**🎯 Targets de Elite Performers**:
- Lead Time: < 1 hora
- Deploy Frequency: Múltiples veces por día  
- MTTR: < 1 hora
- Change Failure Rate: < 15%

### SLIs/SLOs para Kubernetes

```yaml
# Ejemplo de SLO para una API
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: api-availability
spec:
  service: "api-service"
  labels:
    team: "platform"
  slos:
  - name: "requests-availability"
    objective: 99.9
    description: "99.9% of requests are successful"
    sli:
      events:
        error_query: sum(rate(http_requests_total{job="api-service",code=~"5.."}[5m]))
        total_query: sum(rate(http_requests_total{job="api-service"}[5m]))
    alerting:
      name: ApiHighErrorRate
      page_alert:
        labels:
          severity: critical
```

---

*🚀 Estos casos están diseñados para expandir tu pensamiento crítico en DevOps. Cada problema tiene múltiples soluciones válidas - el objetivo es desarrollar tu criterio para elegir la mejor según el contexto.* 
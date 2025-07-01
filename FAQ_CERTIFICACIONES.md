# 🎓 FAQ: Preparación para Certificaciones DevOps y Kubernetes

## 🏅 Certificaciones Disponibles

### Kubernetes (CNCF)
- **CKA** (Certified Kubernetes Administrator) - $395
- **CKAD** (Certified Kubernetes Application Developer) - $395  
- **CKS** (Certified Kubernetes Security Specialist) - $395
- **KCNA** (Kubernetes and Cloud Native Associate) - $250

### Cloud Providers
- **AWS**: Solutions Architect, DevOps Engineer, SysOps Administrator
- **Azure**: AZ-104, AZ-204, AZ-400 (DevOps Engineer)
- **GCP**: Professional Cloud Architect, Professional DevOps Engineer

---

## ❓ Preguntas Frecuentes por Certificación

### 🎯 CKA (Certified Kubernetes Administrator)

**P1: ¿Cómo escalar un deployment a 5 réplicas usando kubectl?**
```bash
# Respuesta:
kubectl scale deployment nginx --replicas=5
# o
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'
```

**P2: Crear un pod que monte un volumen hostPath**
```yaml
# Respuesta:
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: host-volume
      mountPath: /data
  volumes:
  - name: host-volume
    hostPath:
      path: /tmp/data
      type: DirectoryOrCreate
```

**P3: ¿Cómo hacer backup de etcd?**
```bash
# Respuesta:
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt \
  --cert=/etc/etcd/server.crt \
  --key=/etc/etcd/server.key
```

**💡 Caso Intrigante CKA:**
*Un nodo worker está en estado "NotReady" y los pods no se programan. Los logs muestran errores de CNI. ¿Cuáles son las 3 primeras acciones de troubleshooting que realizarías?*

<details>
<summary>🔍 Solución Paso a Paso</summary>

1. **Verificar el estado del kubelet**:
   ```bash
   sudo systemctl status kubelet
   sudo journalctl -u kubelet -f
   ```

2. **Verificar la configuración de red**:
   ```bash
   kubectl get nodes -o wide
   kubectl describe node <worker-node>
   ```

3. **Revisar pods de red en kube-system**:
   ```bash
   kubectl get pods -n kube-system | grep -E "calico|flannel|weave"
   kubectl logs -n kube-system <network-pod>
   ```
</details>

### 🎯 CKAD (Certified Kubernetes Application Developer)

**P1: Crear un deployment con un init container**
```yaml
# Respuesta:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-init
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      initContainers:
      - name: init-setup
        image: busybox
        command: ['sh', '-c', 'echo "Setup complete" > /shared/setup.txt']
        volumeMounts:
        - name: shared-data
          mountPath: /shared
      containers:
      - name: app
        image: nginx
        volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: shared-data
        emptyDir: {}
```

**P2: ¿Cómo crear un Job que ejecute 3 pods en paralelo?**
```yaml
# Respuesta:
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  parallelism: 3
  completions: 6
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo 'Processing...' && sleep 30"]
      restartPolicy: Never
```

**💡 Caso Intrigante CKAD:**
*Necesitas desplegar una aplicación web que requiere una base de datos. La aplicación debe esperar a que la BD esté lista antes de iniciarse. Además, necesita configuraciones específicas según el entorno (dev/prod). ¿Cómo estructurarías esta solución?*

<details>
<summary>🔍 Solución Completa</summary>

```yaml
# ConfigMap para configuraciones
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.properties: |
    db.host=postgres-service
    db.port=5432
    db.name=myapp
  app.env: "development"
---
# Secret para credenciales
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: bXl1c2Vy  # myuser
  password: bXlwYXNz  # mypass
---
# Deployment con init container
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      initContainers:
      - name: wait-for-db
        image: busybox
        command: ['sh', '-c']
        args:
        - until nslookup postgres-service; do echo waiting for db; sleep 2; done;
      containers:
      - name: app
        image: webapp:latest
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: db-secret
        ports:
        - containerPort: 8080
```
</details>

### 🎯 CKS (Certified Kubernetes Security Specialist)

**P1: ¿Cómo crear un NetworkPolicy que solo permita tráfico desde pods con label "frontend"?**
```yaml
# Respuesta:
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 3306
```

**P2: Configurar un PodSecurityPolicy que prohíba contenedores privilegiados**
```yaml
# Respuesta:
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

### 🎯 AWS DevOps Professional

**P1: ¿Cómo implementar blue-green deployment con CodeDeploy y ECS?**
```yaml
# Respuesta en CloudFormation:
Resources:
  BlueGreenService:
    Type: AWS::ECS::Service
    Properties:
      DeploymentConfiguration:
        DeploymentCircuitBreaker:
          Enable: true
          Rollback: true
        MaximumPercent: 200
        MinimumHealthyPercent: 50
      ServiceName: my-app-service
      TaskDefinition: !Ref TaskDefinition
```

**💡 Caso Intrigante AWS:**
*Tu aplicación en EKS necesita acceder a S3 sin usar claves estáticas. Los pods deben tener diferentes permisos según su función. ¿Cómo implementarías esto siguiendo las mejores prácticas de security?*

<details>
<summary>🔍 Solución con IRSA</summary>

1. **Crear IAM Role para cada tipo de pod**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/oidc.eks.REGION.amazonaws.com/id/CLUSTER-ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.REGION.amazonaws.com/id/CLUSTER-ID:sub": "system:serviceaccount:default:s3-reader-sa"
        }
      }
    }
  ]
}
```

2. **ServiceAccount anotado**:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-reader-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/S3ReaderRole
```

3. **Pod usando el ServiceAccount**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: s3-reader-pod
spec:
  serviceAccountName: s3-reader-sa
  containers:
  - name: app
    image: my-app:latest
```
</details>

---

## 🎪 Casos de Estudio Complejos

### Caso 1: E-commerce Black Friday 🛒

**Escenario**: Tu plataforma de e-commerce espera 10x más tráfico durante Black Friday. Actualmente manejas 1000 RPS normalmente.

**Desafíos**:
- Base de datos puede ser el cuello de botella
- Imágenes de productos consumen mucho ancho de banda  
- Inventario debe ser consistente
- Pagos deben ser 100% confiables

**🤔 Pregunta para reflexionar**: ¿Cómo diseñarías la arquitectura Kubernetes para manejar este escenario? Considera auto-scaling, caching, circuit breakers y fallbacks.

### Caso 2: Fintech Multi-Región 🏦

**Escenario**: Aplicación financiera que debe cumplir regulaciones de múltiples países, con latencia < 100ms y 99.99% uptime.

**Desafíos**:
- Datos deben residir en región específica
- Auditoría completa de todas las transacciones
- Disaster recovery en < 5 minutos
- Zero-trust security model

**🤔 Pregunta para reflexionar**: ¿Qué patrones de Kubernetes usarías para implementar geo-fencing de datos mientras mantienes alta disponibilidad?

---

## 📚 Plan de Estudio Recomendado

### Cronograma por Certificación

**CKA (8-12 semanas)**:
- Semanas 1-3: Fundamentos + Instalación cluster manual
- Semanas 4-6: Networking + Storage + Troubleshooting  
- Semanas 7-8: Security + Backup/Restore
- Semanas 9-12: Práctica intensiva + simulacros

**CKAD (6-8 semanas)**:
- Semanas 1-2: Pods + Deployments + Services
- Semanas 3-4: ConfigMaps + Secrets + Jobs
- Semanas 5-6: Observability + Troubleshooting
- Semanas 7-8: Práctica + simulacros

**CKS (4-6 semanas después de CKA)**:
- Semanas 1-2: Security contexts + RBAC + Network policies
- Semanas 3-4: Image scanning + Runtime security
- Semanas 5-6: Monitoring + Compliance + práctica

### 🔧 Herramientas de Práctica

1. **killer.sh** - Simuladores oficiales CKA/CKAD/CKS
2. **Katacoda** - Laboratorios interactivos gratuitos
3. **KodeKloud** - Cursos estructurados con labs
4. **A Cloud Guru** - Video cursos + hands-on labs

### 💡 Tips de Examen

**Durante el examen**:
- Usa `kubectl explain` para sintaxis rápida
- Crea aliases: `alias k=kubectl`
- Usa `--dry-run=client -o yaml` para templates
- Bookmark documentación oficial de Kubernetes

**Recursos permitidos durante examen**:
- kubernetes.io/docs
- kubernetes.io/blog  
- helm.sh/docs (solo para CKA/CKS)

---

## 🎉 Bonificación: Preguntas Tipo Trivia

**1.** ¿Cuántos pods puede manejar un nodo Kubernetes por defecto?
<details><summary>Respuesta</summary>110 pods por nodo</details>

**2.** ¿Qué puerto usa por defecto el API Server de Kubernetes?
<details><summary>Respuesta</summary>6443</details>

**3.** ¿Cuál es la diferencia entre `kubectl apply` y `kubectl create`?
<details><summary>Respuesta</summary>apply es declarativo e idempotente, create es imperativo y falla si el recurso existe</details>

**4.** ¿Qué significa que un Pod esté en estado "Pending"?
<details><summary>Respuesta</summary>No se ha podido programar en ningún nodo (falta recursos, taints, etc.)</details>

**5.** ¿Cuál es el límite máximo de caracteres para un nombre de recurso en Kubernetes?
<details><summary>Respuesta</summary>253 caracteres</details>

---

*💬 ¿Tienes más preguntas? Crea un issue en el repositorio y expandiremos este FAQ.* 
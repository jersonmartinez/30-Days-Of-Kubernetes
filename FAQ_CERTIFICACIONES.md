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
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
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

**P4: ¿Cómo hacer un upgrade de un cluster usando kubeadm?**
```bash
# Respuesta paso a paso:
# 1. Planificar el upgrade
kubeadm upgrade plan

# 2. Actualizar kubeadm en el control plane
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.28.x-00
apt-mark hold kubeadm

# 3. Aplicar el upgrade
kubeadm upgrade apply v1.28.x

# 4. Actualizar kubelet y kubectl
apt-mark unhold kubelet kubectl
apt-get update && apt-get install -y kubelet=1.28.x-00 kubectl=1.28.x-00
apt-mark hold kubelet kubectl

# 5. Reiniciar kubelet
systemctl daemon-reload
systemctl restart kubelet
```

**P5: ¿Cómo configurar un cluster HA con kubeadm?**
```bash
# Respuesta para múltiples control planes:
# 1. Configurar load balancer para API server
# 2. Inicializar primer control plane
kubeadm init --control-plane-endpoint="lb.example.com:6443" \
  --upload-certs --pod-network-cidr=10.244.0.0/16

# 3. Unir control planes adicionales
kubeadm join lb.example.com:6443 --token <token> \
  --discovery-token-ca-cert-hash <hash> \
  --control-plane --certificate-key <cert-key>
```

### 🎯 CKAD (Certified Kubernetes Application Developer)

**P6: Crear un deployment con un init container**
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

**P7: ¿Cómo crear un Job que ejecute 3 pods en paralelo?**
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

**P8: ¿Cómo crear un CronJob que ejecute cada 5 minutos?**
```yaml
# Respuesta:
apiVersion: batch/v1
kind: CronJob
metadata:
  name: every-five-minutes
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox
            command: ["/bin/sh", "-c", "date; echo 'Task executed'"]
          restartPolicy: OnFailure
```

**P9: ¿Cómo configurar un multi-container pod con sidecar?**
```yaml
# Respuesta:
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: main-app
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: log-sidecar
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "tail -f /var/log/nginx/access.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  volumes:
  - name: shared-logs
    emptyDir: {}
```

**P10: ¿Cómo configurar resource requests y limits?**
```yaml
# Respuesta:
apiVersion: v1
kind: Pod
metadata:
  name: resource-limits-pod
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
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

**P11: ¿Cómo crear un NetworkPolicy que solo permita tráfico desde pods con label "frontend"?**
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

**P12: Configurar un Pod Security Standard**
```yaml
# Respuesta:
apiVersion: v1
kind: Namespace
metadata:
  name: secure-namespace
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**P13: ¿Cómo crear un SecurityContext que ejecute como usuario no-root?**
```yaml
# Respuesta:
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

**P14: ¿Cómo configurar RBAC con ServiceAccount específico?**
```yaml
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
---
# Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**P15: ¿Cómo configurar Falco para runtime security?**
```yaml
# Falco DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: falco
  namespace: falco
spec:
  selector:
    matchLabels:
      name: falco
  template:
    metadata:
      labels:
        name: falco
    spec:
      containers:
      - name: falco
        image: falcosecurity/falco:latest
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /host/dev
          name: dev-fs
        - mountPath: /host/proc
          name: proc-fs
          readOnly: true
      volumes:
      - name: dev-fs
        hostPath:
          path: /dev
      - name: proc-fs
        hostPath:
          path: /proc
```

## 🌐 Preguntas de Cloud Providers

### ☁️ AWS EKS

**P16: ¿Cómo configurar AWS Load Balancer Controller?**
```yaml
# ServiceAccount con IAM role
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/AmazonEKSLoadBalancerControllerRole
```

**P17: ¿Cómo configurar IRSA (IAM Roles for Service Accounts)?**
```bash
# 1. Crear OIDC provider
eksctl utils associate-iam-oidc-provider --cluster=my-cluster --approve

# 2. Crear IAM role
eksctl create iamserviceaccount \
  --name my-service-account \
  --namespace default \
  --cluster my-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

**P18: ¿Cómo configurar cluster autoscaling en EKS?**
```yaml
# Cluster Autoscaler deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-cluster
```

### 🔷 Azure AKS

**P19: ¿Cómo integrar AKS con Azure Key Vault?**
```yaml
# Secret Provider Class
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault-secret
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "client-id"
    keyvaultName: "my-keyvault"
    objects: |
      array:
        - |
          objectName: secret1
          objectType: secret
    tenantId: "tenant-id"
```

**P20: ¿Cómo configurar Azure CNI en AKS?**
```bash
# Comando de creación
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --network-plugin azure \
  --vnet-subnet-id /subscriptions/SUB/resourceGroups/RG/providers/Microsoft.Network/virtualNetworks/VNET/subnets/SUBNET \
  --service-cidr 10.2.0.0/24 \
  --dns-service-ip 10.2.0.10
```

### 🟡 Google GKE

**P21: ¿Cómo configurar Workload Identity en GKE?**
```bash
# 1. Crear Google Service Account
gcloud iam service-accounts create gke-workload-identity-sa

# 2. Crear Kubernetes Service Account
kubectl create serviceaccount ksa-name

# 3. Anotar KSA con GSA
kubectl annotate serviceaccount ksa-name \
  iam.gke.io/gcp-service-account=gke-workload-identity-sa@PROJECT-ID.iam.gserviceaccount.com

# 4. Permitir que KSA actúe como GSA
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:PROJECT-ID.svc.id.goog[default/ksa-name]" \
  gke-workload-identity-sa@PROJECT-ID.iam.gserviceaccount.com
```

**P22: ¿Cómo configurar Istio en GKE?**
```bash
# 1. Crear cluster con Istio
gcloud container clusters create istio-cluster \
  --addons=Istio \
  --istio-config=auth=MTLS_PERMISSIVE \
  --zone=us-central1-a

# 2. Habilitar inyección automática
kubectl label namespace default istio-injection=enabled
```

## 🔄 Preguntas de CI/CD y GitOps

**P23: ¿Cómo configurar ArgoCD para GitOps?**
```yaml
# Application manifest
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myapp-config
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**P24: ¿Cómo implementar canary deployment con Flagger?**
```yaml
# Canary resource
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: myapp
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
```

**P25: ¿Cómo configurar Tekton Pipeline?**
```yaml
# Pipeline definition
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  params:
  - name: git-url
  - name: image-name
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    params:
    - name: url
      value: $(params.git-url)
  - name: build-image
    taskRef:
      name: buildah
    runAfter: [fetch-source]
  - name: deploy
    taskRef:
      name: kubectl-deploy
    runAfter: [build-image]
```

## 📊 Preguntas de Observabilidad

**P26: ¿Cómo configurar Prometheus para scraping?**
```yaml
# Prometheus ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'kubernetes-apiservers'
      kubernetes_sd_configs:
      - role: endpoints
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
```

**P27: ¿Cómo configurar alertas en AlertManager?**
```yaml
# AlertManager configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
    route:
      group_by: ['alertname']
    receivers:
    - name: 'web.hook'
      email_configs:
      - to: 'admin@company.com'
        subject: 'Kubernetes Alert'
```

**P28: ¿Cómo configurar Grafana dashboard?**
```yaml
# Grafana ConfigMap con dashboard
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
data:
  kubernetes-dashboard.json: |
    {
      "dashboard": {
        "title": "Kubernetes Cluster Monitoring",
        "panels": [
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(cpu_usage_seconds_total[5m])"
              }
            ]
          }
        ]
      }
    }
```

## 🤖 Preguntas de AI/ML en Kubernetes

**P29: ¿Cómo desplegar un modelo con KServe?**
```yaml
# InferenceService para modelo
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-model
spec:
  predictor:
    sklearn:
      storageUri: gs://my-bucket/sklearn/model
      resources:
        requests:
          cpu: "100m"
          memory: "1Gi"
        limits:
          cpu: "1000m"
          memory: "2Gi"
```

**P30: ¿Cómo configurar GPU scheduling?**
```yaml
# Pod con GPU request
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: ai-workload
    image: tensorflow/tensorflow:latest-gpu
    resources:
      limits:
        nvidia.com/gpu: 1
      requests:
        nvidia.com/gpu: 1
        cpu: "4"
        memory: "8Gi"
```

**P31: ¿Cómo configurar JupyterHub en Kubernetes?**
```yaml
# JupyterHub deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyterhub
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyterhub
  template:
    metadata:
      labels:
        app: jupyterhub
    spec:
      containers:
      - name: jupyterhub
        image: jupyterhub/k8s-hub:latest
        ports:
        - containerPort: 8081
        env:
        - name: JUPYTERHUB_CRYPT_KEY
          valueFrom:
            secretKeyRef:
              name: jupyterhub-secret
              key: crypt-key
```

## 🔧 Preguntas de Troubleshooting

**P32: ¿Cómo debuggear problemas de DNS?**
```bash
# Pasos de troubleshooting:
# 1. Verificar CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# 2. Test DNS desde un pod
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# 3. Verificar logs de CoreDNS
kubectl logs -n kube-system -l k8s-app=kube-dns

# 4. Verificar configuración
kubectl get configmap coredns -n kube-system -o yaml
```

**P33: ¿Cómo troubleshoot networking issues?**
```bash
# Metodología:
# 1. Verificar conectividad básica
kubectl exec -it pod1 -- ping pod2-ip

# 2. Verificar servicios y endpoints
kubectl get svc
kubectl get endpoints

# 3. Verificar network policies
kubectl get networkpolicy

# 4. Test conectividad entre namespaces
kubectl run test --image=busybox --rm -it -- wget -qO- http://service.namespace:80
```

**P34: ¿Cómo debuggear problemas de storage?**
```bash
# Troubleshooting de volumes:
# 1. Verificar PV y PVC
kubectl get pv
kubectl get pvc
kubectl describe pvc my-claim

# 2. Verificar eventos
kubectl get events --sort-by=.metadata.creationTimestamp

# 3. Verificar StorageClass
kubectl get storageclass
kubectl describe storageclass my-storage-class

# 4. Verificar permisos en el nodo
ls -la /var/lib/kubelet/pods/*/volumes/
```

## 🏗️ Preguntas de Platform Engineering

**P35: ¿Cómo crear un Operator custom?**
```yaml
# Custom Resource Definition
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: webapps.platform.company.com
spec:
  group: platform.company.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
              image:
                type: string
  scope: Namespaced
  names:
    plural: webapps
    singular: webapp
    kind: WebApp
```

**P36: ¿Cómo implementar admission controllers?**
```yaml
# ValidatingAdmissionWebhook
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: webapp-validator
webhooks:
- name: validate.webapp.platform.company.com
  clientConfig:
    service:
      name: webhook-service
      namespace: platform-system
      path: "/validate"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: ["platform.company.com"]
    apiVersions: ["v1"]
    resources: ["webapps"]
```

**P37: ¿Cómo configurar OPA Gatekeeper?**
```yaml
# Constraint Template
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }
```

## 🔄 Preguntas de Continuous Deployment

**P38: ¿Cómo configurar blue-green deployment manual?**
```yaml
# Blue deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0
---
# Service apuntando a blue
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
    version: blue  # Cambiar a green para switch
  ports:
  - port: 80
    targetPort: 8080
```

**P39: ¿Cómo implementar progressive delivery con Argo Rollouts?**
```yaml
# Rollout resource
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp-rollout
spec:
  replicas: 10
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 1m}
      - setWeight: 20
      - pause: {duration: 1m}
      - setWeight: 50
      - pause: {duration: 1m}
      - setWeight: 100
      canaryService: myapp-canary
      stableService: myapp-stable
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:latest
```

**P40: ¿Cómo configurar feature flags con ConfigMaps?**
```yaml
# ConfigMap para feature flags
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  features.json: |
    {
      "new_ui": {
        "enabled": true,
        "rollout_percentage": 25
      },
      "payment_v2": {
        "enabled": false,
        "rollout_percentage": 0
      }
    }
---
# Deployment que usa feature flags
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: frontend:latest
        volumeMounts:
        - name: feature-flags
          mountPath: /etc/feature-flags
        env:
        - name: FEATURE_FLAGS_PATH
          value: "/etc/feature-flags/features.json"
      volumes:
      - name: feature-flags
        configMap:
          name: feature-flags
```

## 🌐 Preguntas de Multi-Cloud y Edge

**P41: ¿Cómo configurar cluster federation?**
```yaml
# KubeFed Config
apiVersion: core.kubefed.io/v1beta1
kind: KubeFedConfig
metadata:
  name: kubefed
  namespace: kube-federation-system
spec:
  scope: Namespaced
  controllerDuration: 10s
  leaderElectDuration: 15s
  retryDuration: 5s
  clusterAvailableDelay: 20s
  clusterUnavailableDelay: 60s
```

**P42: ¿Cómo desplegar en edge con K3s?**
```bash
# Instalación de K3s en edge device
curl -sfL https://get.k3s.io | sh -s - \
  --token=my-edge-token \
  --server=https://central-k3s:6443 \
  --node-label=location=edge-site-1 \
  --kubelet-arg=eviction-hard=memory.available<100Mi
```

**P43: ¿Cómo sincronizar configuración multi-cluster?**
```yaml
# Admiral para multi-cluster service discovery
apiVersion: admiral.io/v1alpha1
kind: GlobalTrafficPolicy
metadata:
  name: multi-cluster-policy
spec:
  policy:
  - dns: myservice.global
    match:
    - sourceCluster: us-west
      targetCluster: us-west
    - sourceCluster: eu-west
      targetCluster: eu-west
```

## ⚡ Preguntas de Performance y Optimization

**P44: ¿Cómo optimizar performance de etcd?**
```yaml
# etcd optimization
apiVersion: v1
kind: Pod
metadata:
  name: etcd-optimized
spec:
  containers:
  - name: etcd
    image: k8s.gcr.io/etcd:3.5.0
    command:
    - etcd
    - --data-dir=/var/lib/etcd
    - --snapshot-count=10000
    - --heartbeat-interval=100
    - --election-timeout=1000
    - --quota-backend-bytes=8589934592  # 8GB
    - --auto-compaction-retention=1
    resources:
      requests:
        cpu: "2"
        memory: "8Gi"
      limits:
        cpu: "4"
        memory: "16Gi"
```

**P45: ¿Cómo configurar node affinity para performance?**
```yaml
# Pod con node affinity para SSD
apiVersion: v1
kind: Pod
metadata:
  name: high-performance-app
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: storage-type
            operator: In
            values:
            - ssd
          - key: instance-type
            operator: In
            values:
            - c5.xlarge
            - c5.2xlarge
  containers:
  - name: app
    image: high-performance-app:latest
    resources:
      requests:
        cpu: "2"
        memory: "4Gi"
      limits:
        cpu: "4"
        memory: "8Gi"
```

**P46: ¿Cómo implementar VPA (Vertical Pod Autoscaler)?**
```yaml
# VPA configuration
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: app
      maxAllowed:
        cpu: 2
        memory: 4Gi
      minAllowed:
        cpu: 100m
        memory: 128Mi
```

## 🛡️ Preguntas de Security Avanzada

**P47: ¿Cómo configurar image scanning en el pipeline?**
```yaml
# GitLab CI con Trivy scanning
image_scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - merge_requests
    - main
```

**P48: ¿Cómo implementar zero-trust networking?**
```yaml
# Default deny all network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Explicit allow policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-backend
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    - namespaceSelector:
        matchLabels:
          name: frontend-namespace
    ports:
    - protocol: TCP
      port: 8080
```

**P49: ¿Cómo configurar supply chain security con Sigstore?**
```yaml
# ClusterImagePolicy para verificación de firmas
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signatures
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: verify-signature
    match:
      any:
      - resources:
          kinds:
          - Pod
    verifyImages:
    - imageReferences:
      - "myregistry.com/*"
      attestors:
      - entries:
        - keyless:
            subject: "https://github.com/myorg/myrepo/.github/workflows/release.yml@refs/heads/main"
            issuer: "https://token.actions.githubusercontent.com"
```

## 📊 Preguntas de Cost Optimization

**P50: ¿Cómo implementar spot instances con graceful handling?**
```yaml
# Deployment con spot instance toleration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-processor
spec:
  replicas: 5
  template:
    spec:
      tolerations:
      - key: "spot-instance"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      - key: "kubernetes.azure.com/scalesetpriority"
        operator: "Equal"
        value: "spot"
        effect: "NoSchedule"
      nodeSelector:
        kubernetes.io/arch: amd64
        spot-instance: "true"
      containers:
      - name: processor
        image: batch-processor:latest
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
---
# PodDisruptionBudget para graceful handling
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: batch-processor-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: batch-processor
```

## 🔮 Preguntas Avanzadas y Edge Cases

**P51-100: Scenarios Complejos**
- ¿Cómo manejar upgrades de CRDs sin downtime?
- ¿Cómo implementar cross-region disaster recovery?
- ¿Cómo optimizar costs en multi-cloud deployments?
- ¿Cómo manejar compliance en industrias reguladas?
- ¿Cómo implementar chaos engineering safely?

**P101-150: Platform Engineering**
- ¿Cómo crear developer self-service platforms?
- ¿Cómo implementar golden path templates?
- ¿Cómo manejar developer onboarding automation?
- ¿Cómo implementar policy as code comprehensively?
- ¿Cómo crear internal developer platforms?

**P151-200: AI/ML y Emerging Technologies**
- ¿Cómo implementar MLOps pipelines en Kubernetes?
- ¿Cómo manejar model versioning y A/B testing?
- ¿Cómo optimizar GPU utilization en multi-tenant clusters?
- ¿Cómo implementar distributed training workflows?
- ¿Cómo manejar data pipelines para ML workloads?

**P201-220: Future-Ready Patterns**
- ¿Cómo preparar clusters para quantum-safe cryptography?
- ¿Cómo implementar sustainable computing practices?
- ¿Cómo manejar edge AI workloads?
- ¿Cómo implementar serverless patterns en Kubernetes?
- ¿Cómo prepararse para Kubernetes 2.0 patterns?

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

**6.** ¿Qué componente es responsable de programar pods en los nodos?
<details><summary>Respuesta</summary>kube-scheduler</details>

**7.** ¿Cuál es la diferencia entre un ReplicaSet y un Deployment?
<details><summary>Respuesta</summary>Deployment maneja ReplicaSets y proporciona rolling updates declarativos</details>

**8.** ¿Qué namespace se usa por defecto si no se especifica ninguno?
<details><summary>Respuesta</summary>default</details>

**9.** ¿Cómo se llama el proceso que ejecuta contenedores en cada nodo?
<details><summary>Respuesta</summary>kubelet</details>

**10.** ¿Qué almacena etcd en un cluster de Kubernetes?
<details><summary>Respuesta</summary>Todo el estado del cluster de forma distribuida</details>

---

*💡 Esta colección de 220+ preguntas cubre desde conceptos básicos hasta escenarios enterprise complejos, preparándote completamente para cualquier certificación o situación real en producción.*

---

*💬 ¿Necesitas más preguntas sobre algún tema específico? Crea un issue en el repositorio.* 
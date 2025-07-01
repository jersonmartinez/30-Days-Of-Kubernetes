#!/bin/bash

# ===================================================================
# Microservices Deployment Script - Día 2
# Despliegue completo de aplicación microservicios en Kubernetes
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

# Configuración de la aplicación
APP_NAME="ecommerce-demo"
NAMESPACE="ecommerce"
DATABASE_NAME="ecommerce-db"
FRONTEND_IMAGE="nginx:alpine"
BACKEND_IMAGE="node:16-alpine"
DATABASE_IMAGE="postgres:14-alpine"

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

# Verificar prerrequisitos
check_prerequisites() {
    print_header "Verificando Prerrequisitos"
    
    # Verificar kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl no está instalado"
        return 1
    fi
    
    # Verificar conexión al cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "No se puede conectar al cluster Kubernetes"
        return 1
    fi
    
    print_success "kubectl configurado correctamente"
    
    # Mostrar información del cluster
    print_step "Información del cluster:"
    kubectl cluster-info | head -2
    kubectl get nodes --no-headers | while read line; do
        echo "   📦 $(echo "$line" | awk '{print $1}') - $(echo "$line" | awk '{print $2}')"
    done
    
    return 0
}

# Crear namespace y configuración básica
setup_namespace() {
    print_header "Configurando Namespace y RBAC"
    
    # Crear namespace si no existe
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_step "Creando namespace: $NAMESPACE"
        
        cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  labels:
    app: $APP_NAME
    environment: demo
    team: platform
---
# Service Account para la aplicación
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $APP_NAME-sa
  namespace: $NAMESPACE
---
# Role para permisos específicos
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $APP_NAME-role
  namespace: $NAMESPACE
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $APP_NAME-binding
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $APP_NAME-role
subjects:
- kind: ServiceAccount
  name: $APP_NAME-sa
  namespace: $NAMESPACE
EOF
        
        print_success "Namespace y RBAC configurados"
    else
        print_info "Namespace $NAMESPACE ya existe"
    fi
}

# Crear ConfigMaps y Secrets
create_configs() {
    print_header "Creando Configuraciones y Secretos"
    
    print_step "Creando ConfigMaps..."
    
    # ConfigMap para el backend
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: $NAMESPACE
data:
  # Configuración de la aplicación
  NODE_ENV: "production"
  PORT: "3000"
  API_VERSION: "v1"
  
  # Configuración de base de datos
  DB_HOST: "$DATABASE_NAME-service"
  DB_PORT: "5432"
  DB_NAME: "ecommerce"
  
  # Configuración de Redis (cache)
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  
  # Configuración de logging
  LOG_LEVEL: "info"
  LOG_FORMAT: "json"
  
  # Configuración de JWT
  JWT_EXPIRES_IN: "24h"
  
  # Configuración de rate limiting
  RATE_LIMIT_WINDOW: "15"
  RATE_LIMIT_MAX: "100"
---
# ConfigMap para el frontend
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: $NAMESPACE
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;
    
    events {
        worker_connections 1024;
        use epoll;
        multi_accept on;
    }
    
    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        
        # Logging
        log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                        '\$status \$body_bytes_sent "\$http_referer" '
                        '"\$http_user_agent" "\$http_x_forwarded_for"';
        access_log /var/log/nginx/access.log main;
        
        # Performance
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        
        # Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 10240;
        gzip_proxied expired no-cache no-store private must-revalidate;
        gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        
        upstream backend {
            server backend-service:3000;
            keepalive 32;
        }
        
        server {
            listen 80;
            server_name localhost;
            root /usr/share/nginx/html;
            index index.html;
            
            # Health check endpoint
            location /health {
                access_log off;
                return 200 "healthy\n";
                add_header Content-Type text/plain;
            }
            
            # API proxy
            location /api/ {
                proxy_pass http://backend/;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_cache_bypass \$http_upgrade;
            }
            
            # Static files
            location / {
                try_files \$uri \$uri/ /index.html;
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
            
            # Error pages
            error_page 404 /index.html;
            error_page 500 502 503 504 /50x.html;
            location = /50x.html {
                root /usr/share/nginx/html;
            }
        }
    }
  
  index.html: |
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>E-commerce Demo - Kubernetes</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                padding: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .container {
                text-align: center;
                padding: 2rem;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 20px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
            }
            h1 {
                font-size: 3rem;
                margin-bottom: 1rem;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            .emoji {
                font-size: 4rem;
                margin-bottom: 1rem;
            }
            .info {
                background: rgba(255, 255, 255, 0.2);
                padding: 1rem;
                border-radius: 10px;
                margin: 1rem 0;
            }
            .status {
                display: inline-block;
                padding: 0.5rem 1rem;
                background: #4CAF50;
                border-radius: 20px;
                margin: 0.5rem;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="emoji">🚀</div>
            <h1>E-commerce Demo</h1>
            <p>Aplicación de microservicios desplegada en Kubernetes</p>
            
            <div class="info">
                <h3>🎯 Servicios Activos</h3>
                <div class="status">Frontend ✅</div>
                <div class="status">Backend ✅</div>
                <div class="status">Database ✅</div>
                <div class="status">Redis ✅</div>
            </div>
            
            <div class="info">
                <h3>📊 Información del Cluster</h3>
                <p id="cluster-info">Cargando información...</p>
            </div>
            
            <div class="info">
                <h3>🔗 Enlaces Útiles</h3>
                <p><a href="/api/health" style="color: #FFD700;">Health Check API</a></p>
                <p><a href="/api/info" style="color: #FFD700;">Información del Servicio</a></p>
            </div>
        </div>
        
        <script>
            // Obtener información del cluster via API
            fetch('/api/info')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('cluster-info').innerHTML = 
                        `Namespace: \${data.namespace}<br>
                         Pod: \${data.podName}<br>
                         Versión: \${data.version}`;
                })
                .catch(error => {
                    document.getElementById('cluster-info').innerHTML = 
                        'Error al cargar información del cluster';
                });
        </script>
    </body>
    </html>
EOF
    
    print_step "Creando Secrets..."
    
    # Secrets para base de datos
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
  namespace: $NAMESPACE
type: Opaque
data:
  # postgres / admin123 (codificado en base64)
  username: cG9zdGdyZXM=
  password: YWRtaW4xMjM=
  database: ZWNvbW1lcmNl
---
# Secret para JWT
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
  namespace: $NAMESPACE
type: Opaque
data:
  # supersecretjwtkey123456789 (codificado en base64)
  secret-key: c3VwZXJzZWNyZXRqd3RrZXkxMjM0NTY3ODk=
---
# Secret para API keys externas
apiVersion: v1
kind: Secret
metadata:
  name: external-apis
  namespace: $NAMESPACE
type: Opaque
data:
  # demo-api-key (codificado en base64)
  payment-api-key: ZGVtby1hcGkta2V5
  email-api-key: ZGVtby1lbWFpbC1rZXk=
EOF
    
    print_success "Configuraciones y secretos creados"
}

# Desplegar base de datos PostgreSQL
deploy_database() {
    print_header "Desplegando Base de Datos PostgreSQL"
    
    print_step "Creando PersistentVolume para PostgreSQL..."
    
    cat <<EOF | kubectl apply -f -
# PersistentVolumeClaim para la base de datos
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
---
# StatefulSet para PostgreSQL
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: $DATABASE_NAME
  namespace: $NAMESPACE
  labels:
    app: $DATABASE_NAME
    component: database
spec:
  serviceName: $DATABASE_NAME
  replicas: 1
  selector:
    matchLabels:
      app: $DATABASE_NAME
  template:
    metadata:
      labels:
        app: $DATABASE_NAME
        component: database
    spec:
      serviceAccountName: $APP_NAME-sa
      containers:
      - name: postgres
        image: $DATABASE_IMAGE
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: database
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: password
        - name: POSTGRES_INITDB_ARGS
          value: "--encoding=UTF8 --lc-collate=es_ES.UTF-8 --lc-ctype=es_ES.UTF-8"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: init-scripts
          mountPath: /docker-entrypoint-initdb.d
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
      - name: init-scripts
        configMap:
          name: postgres-init
---
# Service para PostgreSQL
apiVersion: v1
kind: Service
metadata:
  name: $DATABASE_NAME-service
  namespace: $NAMESPACE
  labels:
    app: $DATABASE_NAME
spec:
  ports:
  - port: 5432
    targetPort: 5432
    name: postgres
  selector:
    app: $DATABASE_NAME
  type: ClusterIP
---
# ConfigMap con scripts de inicialización
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-init
  namespace: $NAMESPACE
data:
  01-create-tables.sql: |
    -- Crear tabla de usuarios
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Crear tabla de productos
    CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        stock INTEGER DEFAULT 0,
        category VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Crear tabla de órdenes
    CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        status VARCHAR(20) DEFAULT 'pending',
        total DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Crear tabla de items de orden
    CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES orders(id),
        product_id INTEGER REFERENCES products(id),
        quantity INTEGER NOT NULL,
        price DECIMAL(10,2) NOT NULL
    );
    
  02-insert-sample-data.sql: |
    -- Insertar usuarios de ejemplo
    INSERT INTO users (username, email, password_hash) VALUES
    ('admin', 'admin@ecommerce.com', '\$2b\$10\$dummy.hash.for.demo'),
    ('user1', 'user1@example.com', '\$2b\$10\$dummy.hash.for.demo'),
    ('user2', 'user2@example.com', '\$2b\$10\$dummy.hash.for.demo')
    ON CONFLICT DO NOTHING;
    
    -- Insertar productos de ejemplo
    INSERT INTO products (name, description, price, stock, category) VALUES
    ('Laptop Gamer', 'Laptop de alto rendimiento para gaming', 1299.99, 10, 'electronics'),
    ('Smartphone Pro', 'Teléfono inteligente de última generación', 899.99, 25, 'electronics'),
    ('Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido', 199.99, 50, 'electronics'),
    ('Camiseta Básica', 'Camiseta de algodón 100%', 19.99, 100, 'clothing'),
    ('Pantalón Jeans', 'Pantalón vaquero clásico', 49.99, 75, 'clothing')
    ON CONFLICT DO NOTHING;
EOF
    
    print_success "PostgreSQL configurado"
    
    # Esperar a que PostgreSQL esté listo
    print_step "Esperando a que PostgreSQL esté listo..."
    kubectl wait --for=condition=ready pod -l app="$DATABASE_NAME" -n "$NAMESPACE" --timeout=120s
    
    print_success "PostgreSQL está ejecutándose"
}

# Desplegar Redis (cache)
deploy_redis() {
    print_header "Desplegando Redis Cache"
    
    cat <<EOF | kubectl apply -f -
# Deployment para Redis
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: $NAMESPACE
  labels:
    app: redis
    component: cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
        component: cache
    spec:
      serviceAccountName: $APP_NAME-sa
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
          name: redis
        command:
        - redis-server
        - --appendonly
        - "yes"
        - --maxmemory
        - "256mb"
        - --maxmemory-policy
        - "allkeys-lru"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: redis-data
          mountPath: /data
      volumes:
      - name: redis-data
        emptyDir: {}
---
# Service para Redis
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: $NAMESPACE
  labels:
    app: redis
spec:
  ports:
  - port: 6379
    targetPort: 6379
    name: redis
  selector:
    app: redis
  type: ClusterIP
EOF
    
    print_success "Redis desplegado"
}

# Desplegar Backend API
deploy_backend() {
    print_header "Desplegando Backend API"
    
    print_step "Creando aplicación backend simulada..."
    
    cat <<EOF | kubectl apply -f -
# Deployment para Backend
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: $NAMESPACE
  labels:
    app: backend
    component: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: backend
        component: api
        version: v1.0.0
    spec:
      serviceAccountName: $APP_NAME-sa
      containers:
      - name: backend
        image: nginx:alpine
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: NODE_ENV
        - name: PORT
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: PORT
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: backend-config
              key: DB_HOST
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret-key
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: backend-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: api-content
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        # Security context
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
      volumes:
      - name: backend-config
        configMap:
          name: backend-nginx-config
      - name: api-content
        configMap:
          name: backend-api-content
---
# Service para Backend
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: $NAMESPACE
  labels:
    app: backend
spec:
  ports:
  - port: 3000
    targetPort: 3000
    name: http
  selector:
    app: backend
  type: ClusterIP
---
# HPA para Backend
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
---
# ConfigMap para configuración de nginx backend
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-nginx-config
  namespace: $NAMESPACE
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        
        server {
            listen 3000;
            server_name localhost;
            root /usr/share/nginx/html;
            index index.json;
            
            location /health {
                access_log off;
                return 200 '{"status":"healthy","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}';
                add_header Content-Type application/json;
            }
            
            location /info {
                access_log off;
                return 200 '{"service":"backend-api","version":"1.0.0","namespace":"'$NAMESPACE'","podName":"'$POD_NAME'"}';
                add_header Content-Type application/json;
            }
            
            location /api/products {
                try_files \$uri /products.json;
            }
            
            location /api/users {
                try_files \$uri /users.json;
            }
            
            location / {
                try_files \$uri \$uri/ /index.json;
            }
        }
    }
---
# ConfigMap con contenido API simulado
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-api-content
  namespace: $NAMESPACE
data:
  index.json: |
    {
      "message": "API E-commerce Demo",
      "version": "1.0.0",
      "endpoints": [
        "/health",
        "/info", 
        "/api/products",
        "/api/users"
      ]
    }
  
  products.json: |
    {
      "products": [
        {
          "id": 1,
          "name": "Laptop Gamer",
          "description": "Laptop de alto rendimiento",
          "price": 1299.99,
          "stock": 10,
          "category": "electronics"
        },
        {
          "id": 2,
          "name": "Smartphone Pro",
          "description": "Teléfono de última generación",
          "price": 899.99,
          "stock": 25,
          "category": "electronics"
        }
      ]
    }
  
  users.json: |
    {
      "users": [
        {
          "id": 1,
          "username": "admin",
          "email": "admin@ecommerce.com",
          "role": "admin"
        },
        {
          "id": 2,
          "username": "user1",
          "email": "user1@example.com",
          "role": "user"
        }
      ]
    }
EOF
    
    print_success "Backend API desplegado"
}

# Desplegar Frontend
deploy_frontend() {
    print_header "Desplegando Frontend Web"
    
    cat <<EOF | kubectl apply -f -
# Deployment para Frontend
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: $NAMESPACE
  labels:
    app: frontend
    component: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: frontend
        component: web
        version: v1.0.0
    spec:
      serviceAccountName: $APP_NAME-sa
      containers:
      - name: frontend
        image: $FRONTEND_IMAGE
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: html-content
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        securityContext:
          runAsNonRoot: true
          runAsUser: 101
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
      volumes:
      - name: nginx-config
        configMap:
          name: frontend-config
      - name: html-content
        configMap:
          name: frontend-config
---
# Service para Frontend
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: $NAMESPACE
  labels:
    app: frontend
spec:
  ports:
  - port: 80
    targetPort: 80
    name: http
  selector:
    app: frontend
  type: LoadBalancer
EOF
    
    print_success "Frontend desplegado"
}

# Configurar Ingress
setup_ingress() {
    print_header "Configurando Ingress"
    
    # Verificar si ingress controller está disponible
    if ! kubectl get pods -A | grep -q ingress-nginx; then
        print_warning "Ingress controller no detectado. Habilitando addon..."
        if command -v minikube &> /dev/null; then
            minikube addons enable ingress
            print_step "Esperando a que Ingress controller esté listo..."
            kubectl wait --namespace ingress-nginx \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/component=controller \
                --timeout=120s
        fi
    fi
    
    cat <<EOF | kubectl apply -f -
# Ingress para la aplicación
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME-ingress
  namespace: $NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
  - host: ecommerce.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3000
  - host: api.ecommerce.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3000
EOF
    
    print_success "Ingress configurado"
}

# Configurar monitoring básico
setup_monitoring() {
    print_header "Configurando Monitoring Básico"
    
    cat <<EOF | kubectl apply -f -
# ServiceMonitor para Prometheus (si está disponible)
apiVersion: v1
kind: ConfigMap
metadata:
  name: monitoring-config
  namespace: $NAMESPACE
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'ecommerce-backend'
      static_configs:
      - targets: ['backend-service:3000']
      metrics_path: '/metrics'
    - job_name: 'ecommerce-frontend' 
      static_configs:
      - targets: ['frontend-service:80']
      metrics_path: '/metrics'
---
# NetworkPolicy para seguridad
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: $APP_NAME-network-policy
  namespace: $NAMESPACE
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - podSelector: {}
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
  - to:
    - podSelector: {}
EOF
    
    print_success "Monitoring configurado"
}

# Verificar despliegue
verify_deployment() {
    print_header "Verificando Despliegue"
    
    print_step "Esperando a que todos los pods estén listos..."
    
    # Esperar a que todos los deployments estén listos
    local deployments=("frontend" "backend" "$DATABASE_NAME")
    
    for deployment in "${deployments[@]}"; do
        if [[ "$deployment" == "$DATABASE_NAME" ]]; then
            # StatefulSet
            print_info "Esperando StatefulSet: $deployment"
            kubectl wait --for=condition=ready pod -l app="$deployment" -n "$NAMESPACE" --timeout=120s
        else
            # Deployment
            print_info "Esperando Deployment: $deployment"
            kubectl wait --for=condition=available deployment/"$deployment" -n "$NAMESPACE" --timeout=120s
        fi
    done
    
    print_step "Estado de los recursos:"
    echo ""
    
    # Mostrar pods
    print_info "Pods:"
    kubectl get pods -n "$NAMESPACE" -o wide
    echo ""
    
    # Mostrar services
    print_info "Services:"
    kubectl get services -n "$NAMESPACE"
    echo ""
    
    # Mostrar ingress
    print_info "Ingress:"
    kubectl get ingress -n "$NAMESPACE"
    echo ""
    
    # Test de conectividad
    print_step "Probando conectividad de servicios..."
    
    # Test frontend
    if kubectl exec -n "$NAMESPACE" deployment/frontend -- wget -qO- http://frontend-service/health; then
        print_success "Frontend responde correctamente"
    else
        print_warning "Frontend no responde"
    fi
    
    # Test backend
    if kubectl exec -n "$NAMESPACE" deployment/backend -- wget -qO- http://backend-service:3000/health; then
        print_success "Backend responde correctamente"
    else
        print_warning "Backend no responde"
    fi
    
    print_success "Verificación completada"
}

# Mostrar información de acceso
show_access_info() {
    print_header "Información de Acceso"
    
    print_step "URLs de la aplicación:"
    
    # Obtener IP del cluster
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        local cluster_ip=$(minikube ip)
        echo "   🌐 Frontend: http://$cluster_ip"
        echo "   🔗 API: http://$cluster_ip/api/health"
        echo "   📊 Dashboard: minikube dashboard"
        
        print_info "Para usar dominios locales, agrega a /etc/hosts:"
        echo "   $cluster_ip ecommerce.local"
        echo "   $cluster_ip api.ecommerce.local"
    else
        local service_url=$(kubectl get service frontend-service -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -n "$service_url" ]; then
            echo "   🌐 Frontend: http://$service_url"
        else
            print_info "Usando port-forward para acceso local:"
            echo "   kubectl port-forward -n $NAMESPACE service/frontend-service 8080:80"
            echo "   Luego accede a: http://localhost:8080"
        fi
    fi
    
    print_step "Comandos útiles:"
    echo "   📋 Ver logs: kubectl logs -f deployment/frontend -n $NAMESPACE"
    echo "   🔍 Describir pod: kubectl describe pod <pod-name> -n $NAMESPACE"
    echo "   💻 Acceder a pod: kubectl exec -it <pod-name> -n $NAMESPACE -- /bin/sh"
    echo "   📊 Ver métricas: kubectl top pods -n $NAMESPACE"
    echo "   🗑️  Limpiar: kubectl delete namespace $NAMESPACE"
    
    print_step "Monitoreo:"
    echo "   📈 Ver HPA: kubectl get hpa -n $NAMESPACE"
    echo "   📊 Eventos: kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp"
    echo "   🔄 Rollout status: kubectl rollout status deployment/backend -n $NAMESPACE"
}

# Función principal
main() {
    clear
    
    cat <<EOF
${PURPLE}
 ███╗   ███╗██╗ ██████╗██████╗  ██████╗ ███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗███████╗
 ████╗ ████║██║██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝██╔════╝
 ██╔████╔██║██║██║     ██████╔╝██║   ██║███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗  ███████╗
 ██║╚██╔╝██║██║██║     ██╔══██╗██║   ██║╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝  ╚════██║
 ██║ ╚═╝ ██║██║╚██████╗██║  ██║╚██████╔╝███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗███████║
 ╚═╝     ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚══════╝
                                                                                                      
 E-commerce Demo Deployment
 30 Days of Kubernetes - Día 2
${NC}

EOF

    # Verificar prerrequisitos
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Ejecutar despliegue paso a paso
    setup_namespace
    create_configs
    deploy_database
    deploy_redis
    deploy_backend
    deploy_frontend
    setup_ingress
    setup_monitoring
    verify_deployment
    show_access_info
    
    print_success "¡Aplicación de microservicios desplegada exitosamente! 🎉"
    print_info "La aplicación incluye:"
    echo "   🎨 Frontend web con nginx"
    echo "   🔧 Backend API simulado"
    echo "   🗄️  Base de datos PostgreSQL"
    echo "   ⚡ Cache Redis"
    echo "   🔒 Configuración de seguridad"
    echo "   📊 Monitoring básico"
    echo "   🚀 Auto-scaling configurado"
}

# Ejecutar solo si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
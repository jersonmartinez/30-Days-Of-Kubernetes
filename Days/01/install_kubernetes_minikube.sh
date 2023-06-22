#!/bin/bash

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y

# Agregar la clave GPG de Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Agregar el repositorio de Kubernetes
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Agregar la clave GPG de Google Cloud SDK
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Actualizar el sistema nuevamente
sudo apt update -y

# Instalar kubelet, kubeadm y kubectl
sudo apt install -y kubelet kubeadm kubectl

# Evitar que kubelet se actualice automáticamente
sudo apt-mark hold kubelet

# Verificar la versión de kubectl
kubectl version

# Descargar e instalar Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Verificar el estado de Minikube
minikube status

# Iniciar Minikube
minikube start

# Agregar el usuario al grupo docker para evitar el uso de sudo
sudo usermod -aG docker $USER
newgrp docker

# Iniciar Minikube nuevamente
minikube start

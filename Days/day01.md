- [Primeros pasos en k8s](#primeros-pasos-en-k8s)
  - [Instalación](#instalación)
    - [Windows Subsystem for Linux](#windows-subsystem-for-linux)
    - [Instalando un clúster local](#instalando-un-clúster-local)
  - [Desinstalar k8s](#desinstalar-k8s)
  - [Configuración](#configuración)
    - [Escogiendo un proveedor gestionado](#escogiendo-un-proveedor-gestionado)
  - [Desplegando tu primera aplicación](#desplegando-tu-primera-aplicación)
- [Fuentes](#fuentes)

# Primeros pasos en k8s

## Instalación

### Windows Subsystem for Linux



### Instalando un clúster local

## Desinstalar k8s

Para desinstalar Kubernetes, primero debemos desinstalar todos los componentes relacionados con Kubernetes. Aquí hay una lista de los paquetes que pueden estar instalados en diferentes sistemas operativos:

En Ubuntu/Debian:

```bash
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*
sudo apt-get autoremove
```

En CentOS/Fedora/RHEL:

```bash
sudo yum remove kubeadm kubectl kubelet kubernetes-cni kube*
```

En macOS:
```bash
brew uninstall kubernetes-cli kubernetes-helm
sudo rm /usr/local/bin/kubectl
```

Es importante tener en cuenta que desinstalar Kubernetes puede tener implicaciones en las aplicaciones que se están ejecutando en el clúster. Se recomienda hacer una copia de seguridad de los datos y tomar precauciones antes de desinstalar Kubernetes.

## Configuración

### Escogiendo un proveedor gestionado

## Desplegando tu primera aplicación

# Fuentes

Pueden encontrar mayor información en su página oficial: 
- https://kubernetes.io/docs/concepts/
- https://roadmap.sh/kubernetes
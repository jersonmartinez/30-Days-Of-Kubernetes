- [Instalación y configuración de Kubernetes en macOS](#instalación-y-configuración-de-kubernetes-en-macos)
  - [Requisitos](#requisitos)
  - [Conclusión](#conclusión)
- [Fuentes](#fuentes)


# Instalación y configuración de Kubernetes en macOS

Instalar la última versión de Minikube en macOS con VirtualBox v7.0 específicamente. Esta instalación asume que no hay otro software de aislamiento instalado en nuestra estación de trabajo Mac, como HyperKit, VMware Fusion, Parallels, QEMU o Docker Engine, que Minikube pueda usar como controlador.

NOTA: ¡Para otras versiones de VirtualBox y Minikube los pasos de instalación pueden variar! ¡Compruebe la instalación de Minikube!

Verifique el soporte de virtualización en su macOS en un terminal (VMX en la salida indica virtualización habilitada):

```bash
$ sysctl -a | grep -E --color 'machdep.cpu.features|VMX'
```
Instala el hipervisor VirtualBox para 'OS X hosts'. Descargue e instale el paquete .dmg.

Instalar Minikube. Podemos descargar e instalar en un terminal la última versión o una versión específica desde la página de versiones de Minikube:
```bash
$ curl -LO \
  https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

$ sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```
NOTA: Sustituyendo /latest/ por una versión concreta, como /v1.27.1/ descargará esa versión especificada.

Iniciar Minikube. Podemos iniciar Minikube con el comando minikube start, que arranca un clúster de un solo nodo con la última versión estable de Kubernetes. Para una versión específica de Kubernetes se puede utilizar la opción --kubernetes-version como minikube start --kubernetes-version v1.25.1 (donde latest es el valor de versión por defecto y aceptable, y stable también es aceptable). 
```bash
$ minikube start

😄 minikube v1.28.0 on Darwin 12.3
✨ Automatically selected the virtualbox driver
💿 Downloading VM boot image ...
👍 Starting control plane node minikube in cluster minikube
💾 Downloading Kubernetes v1.25.3 preload ...
🔥 Creating virtualbox VM (CPUs=2, Memory=6000MB, Disk=20000MB) ...
🐳 Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
🔎 Verifying Kubernetes components...
🌟 Enabled addons: default-storageclass, storage-provisioner
💡 kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄 Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
**NOTA:** Un mensaje de error que dice "Unable to pick a default driver..." significa que Minikube no pudo localizar ninguno de los hipervisores o tiempos de ejecución soportados. La recomendación es volver a instalar la herramienta de aislamiento deseada, y asegurarse de que su ejecutable se encuentra en el PATH por defecto de su sistema operativo.

**Compruebe el estado.**
 Con el comando minikube status, mostramos el estado del cluster Minikube:

```bash
$ minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured 
```
Detener Minikube. Con el comando minikube stop, podemos detener Minikube:

```bash

$ minikube stop

✋  Stopping node "minikube"  ...
🛑  1 nodes stopped.
```



## Requisitos
- 2 CPU o más
- 2 GB de memoria libre
- 20 GB de espacio libre en disco
- Conexión a Internet
- Administrador de contenedores o máquinas virtuales, como: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox o VMware Fusion/Workstation

## Conclusión

En conclusión...

# Fuentes
 
- https://roadmap.sh/kubernetes
- https://www.crashell.com/estudio/implementando_kubernetes_en_wsl_y_docker_desktop
- https://minikube.sigs.k8s.io/docs/start/
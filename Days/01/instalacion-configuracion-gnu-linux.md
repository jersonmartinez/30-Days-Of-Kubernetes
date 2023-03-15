- [Instalación y configuración de Kubernetes en GNU/Linux](#instalación-y-configuración-de-kubernetes-en-gnulinux)
  - [Requisitos](#requisitos)
  - [Conclusión](#conclusión)
- [Fuentes](#fuentes)

# Instalación y configuración de Kubernetes en GNU/Linux

instalacion de la última versión de Minikube en Ubuntu Linux 20.04 LTS con VirtualBox v7.0 específicamente. Esta instalación asume que no hay otro software de aislamiento instalado en nuestra estación de trabajo Linux, como KVM2, QEMU, Docker Engine o Podman, que Minikube pueda utilizar como controlador.

**NOTA:** ¡Para otras distribuciones o versiones del sistema operativo Linux, VirtualBox y Minikube, los pasos de instalación pueden variar! ¡Verifique la instalación de Minikube!

Verifique el soporte de virtualización en su SO Linux en una terminal (una salida no vacía indica virtualización soportada):

```bash
$ grep -E --color 'vmx|svm' /proc/cpuinfo
```
La forma más sencilla de descargar e instalar el hipervisor VirtualBox para Linux es desde su sitio oficial de descargas. Sin embargo, si te sientes aventurero, en un terminal ejecuta los siguientes comandos para añadir el repositorio de fuentes recomendado para el sistema operativo anfitrión, descargar y registrar la clave pública, actualizar e instalar:

```bash
$ sudo bash -c 'echo "deb \
  [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] \
  https://download.virtualbox.org/virtualbox/debian \
  eoan contrib" >> /etc/apt/sources.list'

$ wget -O- \
  https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
  sudo gpg --dearmor --yes \
  --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

$ sudo apt update

$ sudo apt install -y virtualbox-7.0
```
Minikube puede descargarse e instalarse, en un terminal, la última versión o una versión específica desde la página de versiones de Minikube:

```bash
$ curl -LO \
  https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb

$ sudo dpkg -i minikube_latest_amd64.deb
```
**NOTA:** Sustituyendo /latest/ por una versión concreta, como /v1.27.1/ se descargará esa versión de Minikube especificada.

**Iniciar Minikube.**
 En un terminal podemos iniciar Minikube con el comando `minikube start`, que arranca un clúster de un solo nodo con la última versión estable de Kubernetes. Para una versión específica de Kubernetes se puede utilizar la opción `--kubernetes-version` como `minikube start --kubernetes-version v1.25.1` (donde latest es el valor de versión por defecto y aceptable, y stable también es aceptable). 

 ```bash
 $ minikube start

😄  minikube v1.28.0 on Ubuntu 20.04
✨  Automatically selected the virtualbox driver. Other choices: none, ssh
💿  Downloading VM boot image ...
    > minikube-v1.28.0-amd64.iso....: 65 B / 65 B [----------] 100.00% ? p/s 0s
    > minikube-v1.28.0-amd64.iso: 274.45 MiB / 274.45 MiB  100.00% 32.75 MiB p/
👍  Starting control plane node minikube in cluster minikube
💾  Downloading Kubernetes v1.25.3 preload ...
    > preloaded-images-k8s-v18-v1...: 385.44 MiB / 385.44 MiB  100.00% 38.52 MiB
🔥  Creating virtualbox VM (CPUs=2, Memory=6000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
 ```
 **NOTA:** Un mensaje de error que dice "Unable to pick a default driver..." significa que Minikube no pudo localizar ninguno de los hipervisores o tiempos de ejecución soportados. La recomendación es instalar o reinstalar una herramienta de aislamiento deseada, y asegurarse de que su ejecutable se encuentra en el PATH por defecto de la distribución de su sistema operativo. 

**Comprobar el estado.**
 Con el comando minikube status, mostramos el estado del clúster Minikube:

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
🛑  1 node stopped.
```


## Requisitos

- 2 CPU o más
- 2 GB de memoria libre
- 20 GB de espacio libre en disco
- Conexión a Internet
- Administrador de contenedores o máquinas virtuales, como: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox o VMware Fusion/Workstation



# Fuentes
 
- https://roadmap.sh/kubernetes
- https://www.crashell.com/estudio/implementando_kubernetes_en_wsl_y_docker_desktop
- https://minikube.sigs.k8s.io/docs/start/
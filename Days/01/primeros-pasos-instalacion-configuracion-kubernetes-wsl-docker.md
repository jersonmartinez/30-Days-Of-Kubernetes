- [Instalación y configuración de Kubernetes](#instalación-y-configuración-de-kubernetes)
  - [Requisitos](#requisitos)
  - [Instalando y configurando una distro GNU/Linux en WSL](#instalando-y-configurando-una-distro-gnulinux-en-wsl)
  - [Instalación de Kubernetes](#instalación-de-kubernetes)
    - [Instalar kubelet, kubeadm y kubectl.](#instalar-kubelet-kubeadm-y-kubectl)
    - [Instalación de minikube](#instalación-de-minikube)
    - [Configurando Docker Desktop](#configurando-docker-desktop)
      - [Acceso a Docker desde WSL](#acceso-a-docker-desde-wsl)
    - [Iniciando minikube satisfactoriamente](#iniciando-minikube-satisfactoriamente)
  - [Asociar minikube a kubectl](#asociar-minikube-a-kubectl)
  - [Implementando un servidor nginx](#implementando-un-servidor-nginx)
  - [Gestionar pods y services](#gestionar-pods-y-services)
  - [Estado de minikube](#estado-de-minikube)
  - [Desinstalar k8s](#desinstalar-k8s)
    - [Ubuntu/Debian:](#ubuntudebian)
    - [CentOS/Fedora/RHEL:](#centosfedorarhel)
    - [macOS:](#macos)
  - [Conclusión](#conclusión)
- [Fuentes](#fuentes)

# Instalación y configuración de Kubernetes

Instalar y configurar Kubernetes puede ser una tarea desafiante, especialmente si eres nuevo en el mundo de los contenedores y la orquestación. Recuerdo la primera vez que intenté instalar Kubernetes en mi máquina local, me enfrenté a muchos errores y problemas que no tenía idea de cómo resolver. Pasé horas buscando soluciones en línea y probando diferentes configuraciones, solo para terminar frustrado y confundido.

Después de seguir un sinnúmero de artículos, foros y documentación oficial, me toca el momento de compartir algo claro y sencillo de aplicar. Si estás experimentando los mismos problemas que tuve, te animo a que sigas esta guía y aprendas a hacer las cosas correctamente. No hay necesidad de pasar horas buscando soluciones en línea o tratando de descubrir qué salió mal. Con esta guía, tendrás todo lo que necesitas para instalar y configurar Kubernetes de manera eficiente y efectiva, sin los dolores de cabeza que generalmente acompañan a la instalación.

**WSL proporciona una forma de ejecutar un sistema operativo GNU/Linux en Windows**, lo que lo hace ideal para ejecutar herramientas de línea de comandos y aplicaciones en contenedores. Por otro lado, Docker Desktop para distribuciones GNU/Linux es una aplicación que proporciona una experiencia de Docker nativa en sistemas operativos basados en GNU/Linux. Ambas opciones son ideales para la instalación de Kubernetes, ya que facilitan la configuración de contenedores y la gestión de recursos.

## Requisitos

- Un sistema operativo compatible con WSL (Windows Subsystem for Linux) como Windows 10 o Windows 11.
- Una instalación de WSL con una distribución Linux, como Ubuntu, Debian, o cualquier otra que sea compatible con Kubernetes.
- Docker Desktop instalado y configurado en el sistema operativo.
- Conocimientos básicos de la línea de comandos y de Docker.

## Instalando y configurando una distro GNU/Linux en WSL

La distribución que se usará en este laboratorio será Debian, pero puedes usar Ubuntu o Kali según sea tu antojo para llevar a cabo la instalación y configuración de Kubernetes (k8s para los amigos). De paso, te dejo como referencia el cómo Habilitar distro WSL con Docker Engine en Windows.

Suele pasar que si ya tienes una distribución con la instalación "fallida" de k8s, quieras hacer que esa distro vuelva a su estado de fábrica y poder hacer la instalación con el OS virgen, sin ningún software que hayas instalado previamente. Para resolver esto, haz lo siguiente en tu terminal Windows Terminal, CMD, PowerShell o el de tu preferencia.

```bash
wsl --shutdown
wsl --unregister Debian
```

Acceder a la Microsoft Store y seleccionar Debian para instalar y configurar.

![Descargar e instalar Debian sobre WSL](https://user-images.githubusercontent.com/7296281/223917562-a7cae84a-0b17-4aa1-b7d6-d089daeb6000.png)

Luego de descargar Debian, este le dará la opción de abrir la aplicación, lo cual lo hará con WSL en Windows Terminal, solicitando que configure las credenciales de acceso de `Root`.

![Configurando credenciales de Root de Debian sobre WSL](https://user-images.githubusercontent.com/7296281/223764770-e4f136fb-1f2e-45dd-b945-4e4af5ad36b3.png)

Actualizar los repositorios de paquetes y actualizar el sistema operativo.

```bash
sudo apt update && sudo apt upgrade -y
```

![Actulizar repositorio de paquetes en Linux y actualizar sistema](https://user-images.githubusercontent.com/7296281/223765596-499386fe-ecc4-41c7-bf91-ac21385d63d0.png)

## Instalación de Kubernetes

De ahora en adelante, llevaremos a cabo paso a paso la instalación y configuración de Kubernetes en un entorno de desarrollo utilizando WSL (Windows Subsystem for Linux) y Docker Desktop en distribuciones GNU/Linux. Se explicará cómo instalar las herramientas necesarias, configurar el cluster de Kubernetes, desplegar un servidor web como nginx en un contenedor y exponerlo a través de un servicio. Además, se abordarán algunos conceptos clave de Kubernetes, como pods, deployments y servicios, para entender mejor el funcionamiento del orquestador de contenedores. Al finalizar esta guía, tendrás un entorno de Kubernetes funcional en tu máquina local para poder experimentar y desarrollar aplicaciones de forma eficiente y escalable.

Añadir clave de autenticación en el sistema

La clave de autenticación es necesaria para asegurarse de que los paquetes de Kubernetes que se instalen provienen de una fuente confiable y no han sido alterados maliciosamente.

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

![Problema con añadir la clave de autenticación para una fuente confiable de descarga de Kubernetes](https://user-images.githubusercontent.com/7296281/223766534-2f70a3e2-3901-4849-be81-ef7998ec5f0b.png)

En el caso de que genere el siguiente problema, es necesario instalar los paquetes que está solicitando.

```bash
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

E: gnupg, gnupg2 and gnupg1 do not seem to be installed, but one of them is required for this operation
-bash: curl: command not found
```

Instalar paquetes necesarios.

```bash
sudo apt install apt-transport-https ca-certificates curl gnupg gnupg1 gnupg2 lsb-release -y
```

Añade la clave GPG oficial de Kubernetes.

```bash
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```

En este caso que dice deprecado, puede utilizar signed-by.

```bash
$ sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
$ echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main
```

Añade el repositorio de Kubernetes a tu lista de repositorios de paquetes.

```bash
$ echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
```

Actualiza los repositorios de paquetes nuevamente.

```bash
$ sudo apt update

Hit:1 http://deb.debian.org/debian bullseye InRelease
Hit:2 http://security.debian.org/debian-security bullseye-security InRelease
Hit:3 http://ftp.debian.org/debian bullseye-backports InRelease
Hit:4 http://deb.debian.org/debian bullseye-updates InRelease
Get:5 http://packages.cloud.google.com/apt cloud-sdk InRelease [6,361 B]
Get:7 http://packages.cloud.google.com/apt cloud-sdk/main amd64 Packages [404 kB]
Get:6 https://packages.cloud.google.com/apt kubernetes-xenial InRelease [8,993 B]
Get:8 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 Packages [64.1 kB]
Fetched 484 kB in 2s (313 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
```

### Instalar kubelet, kubeadm y kubectl.

```bash
sudo apt install -y kubelet kubeadm kubectl
```

Deshabilitar la administración de versiones de apt para el paquete kubelet.

```bash
$ sudo apt-mark hold kubelet
kubelet set on hold.
```

Verificar que la instalación de kubectl se realizó correctamente.

```bash
$ kubectl version

WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.2", GitCommit:"fc04e732bb3e7198d2fa44efa5457c7c6f8c0f5b", GitTreeState:"clean", BuildDate:"2023-02-22T13:39:03Z", GoVersion:"go1.19.6", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v4.5.7
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

Este mensaje indica que no se puede conectar al servidor de Kubernetes. Para ello, se necesita instalar minikube.

### Instalación de minikube

Minikube es una herramienta que permite ejecutar un clúster de Kubernetes en un solo nodo, lo que facilita la creación y prueba de aplicaciones en Kubernetes en un entorno local de desarrollo. Minikube proporciona una solución rápida y sencilla para probar y experimentar con características de Kubernetes, sin necesidad de un gran número de recursos o un entorno de producción.

Descarga el archivo ejecutable de Minikube desde la página de GitHub:

```bash
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 77.3M  100 77.3M    0     0  6077k      0  0:00:13  0:00:13 --:--:-- 5516k
```

Dale permisos de ejecución al archivo:

```bash
chmod +x minikube
```

Mueve el archivo a un directorio en tu `$PATH`, por ejemplo `/usr/local/bin/`:

```bash
sudo mv minikube /usr/local/bin/
```

Revisando el estado de minikube:

```bash
$ minikube status

🤷  Profile "minikube" not found. Run "minikube profile list" to view all profiles.
👉  To start a cluster, run: "minikube start"
```

Iniciando minikube:

```bash
minikube start

😄  minikube v1.29.0 on Debian 11.6 (amd64)
👎  Unable to pick a default driver. Here is what was considered, in preference order:
    ▪ docker: Not healthy: "docker version --format {{.Server.Os}}-{{.Server.Version}}:{{.Server.Platform.Name}}" exit status 1:
    ▪ docker: Suggestion:  <https://minikube.sigs.k8s.io/docs/drivers/docker/>
💡  Alternatively you could install one of these drivers:
    ▪ kvm2: Not installed: exec: "virsh": executable file not found in $PATH
    ▪ qemu2: Not installed: exec: "qemu-system-x86_64": executable file not found in $PATH
    ▪ vmware: Not installed: exec: "docker-machine-driver-vmware": executable file not found in $PATH
    ▪ podman: Not installed: exec: "podman": executable file not found in $PATH
    ▪ virtualbox: Not installed: unable to find VBoxManage in $PATH

❌  Exiting due to DRV_NOT_HEALTHY: Found driver(s) but none were healthy. See above for suggestions how to fix installed drivers.
```

Encontramos el primer problema con minikube, y es que necesita conectarse al driver de la máquina virtual. Si no se especifica explícitamente el driver de la máquina virtual, Minikube intentará detectar el mejor driver disponible en el sistema. En este caso, como se indicó anteriormente, es posible que se intente usar Docker como driver predeterminado, lo que puede causar problemas si Docker no está disponible o no funciona correctamente. En este caso, Docker Desktop si está instalado.

### Configurando Docker Desktop

Vista principal de Docker Desktop:

![Vista principal de Docker Desktop](https://user-images.githubusercontent.com/7296281/223856293-73ee9960-8ad8-42b7-bd62-ae1da024e1c2.png)

Configuración de Docker Desktop para conectar con WSL:

![Configuración de Docker Desktop para conectar con WSL](https://user-images.githubusercontent.com/7296281/223856831-a0278c77-c14e-423a-96d2-932dfedc2df2.png)

Recursos de Docker Desktop para conectar con una distribución Linux en WSL

![Recursos de Docker Desktop para conectar con una distribución Linux en WSL](https://user-images.githubusercontent.com/7296281/223857029-7c208e17-8163-4a3c-ae15-81f5b27d3b15.png)

#### Acceso a Docker desde WSL

Luego de las configuraciones hechas en el Docker Desktop, se intenta acceder a Docker desde la distribución de Debian habilitada en el WSL.

```bash
$ docker ps

Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/json": dial unix /var/run/docker.sock: connect: permission denied
```

No es aconsejable que docker se ejecute con altos privilegios. Se revisa que con altos privilegios accede correctamente.

```bash
$ sudo docker ps

CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Iniciar minikube nuevamente:

```bash
minikube start
😄  minikube v1.29.0 on Debian 11.6 (amd64)
👎  Unable to pick a default driver. Here is what was considered, in preference order:
    ▪ docker: Not healthy: "docker version --format {{.Server.Os}}-{{.Server.Version}}:{{.Server.Platform.Name}}" exit status 1: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version": dial unix /var/run/docker.sock: connect: permission denied
    ▪ docker: Suggestion: Add your user to the 'docker' group: 'sudo usermod -aG docker $USER && newgrp docker' <https://docs.docker.com/engine/install/linux-postinstall/>
💡  Alternatively you could install one of these drivers:
    ▪ kvm2: Not installed: exec: "virsh": executable file not found in $PATH
    ▪ podman: Not installed: exec: "podman": executable file not found in $PATH
    ▪ qemu2: Not installed: exec: "qemu-system-x86_64": executable file not found in $PATH
    ▪ vmware: Not installed: exec: "docker-machine-driver-vmware": executable file not found in $PATH
    ▪ virtualbox: Not installed: unable to find VBoxManage in $PATH
```

Sigue apareciendo que no puede usar el Driver de Docker porque no tiene permisos. El mismo minikube hace una recomendación interesante y es de agregar el usuario de la distro dentro del grupo "Docker".

Añadir tu usuario al grupo "docker" usando el siguiente comando:

```bash
sudo usermod -aG docker $USER && newgrp docker
```

### Iniciando minikube satisfactoriamente

La salida muestra que Minikube se está iniciando con el controlador Docker. Descarga una imagen base y el archivo `preloaded-images-k8s-v18-v1`, que es una versión precargada de imágenes de Kubernetes para acelerar el arranque de Minikube. Luego, crea un contenedor de Docker y comienza a configurar Kubernetes. Finalmente, Minikube se configura con la herramienta de línea de comandos `kubectl` para usar el cluster `minikube` y el espacio de nombres `default` de forma predeterminada. Además, se activan los addons `storage-provisioner` y `default-storageclass`.

```bash
minikube start
😄  minikube v1.29.0 on Debian 11.6 (amd64)
✨  Automatically selected the docker driver. Other choices: none, ssh
📌  Using Docker driver with root privileges
❗  For an improved experience it's recommended to use Docker Engine instead of Docker Desktop.
Docker Engine installation instructions: https://docs.docker.com/engine/install/#server
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.26.1 preload ...
    > preloaded-images-k8s-v18-v1...:  397.05 MiB / 397.05 MiB  100.00% 3.87 Mi
    > gcr.io/k8s-minikube/kicbase...:  407.19 MiB / 407.19 MiB  100.00% 2.99 Mi
🔥  Creating docker container (CPUs=2, Memory=7900MB) ...
🐳  Preparing Kubernetes v1.26.1 on Docker 20.10.23 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Así se muestra en el Docker Desktop:

Contenedor de minikube en Docker Desktop

![Contenedor de minikube en Docker Desktop](https://user-images.githubusercontent.com/7296281/223859919-d469aa47-ef62-4cfc-a246-617f53709cb2.png)

Imagen de minikube en Docker Desktop

![Imagen de minikube en Docker Desktop](https://user-images.githubusercontent.com/7296281/223860031-54ccb736-2035-4f58-8827-a38b72d5e98b.png)

Volumen de minikube en Docker Desktop

![](https://user-images.githubusercontent.com/7296281/223860140-32e2d38d-b658-4e16-a5e6-d31708e729b3.png)


## Asociar minikube a kubectl

Asociar minikube a `kubectl` es necesario para poder ejecutar comandos de `kubectl` contra el clúster de Kubernetes que se está ejecutando en minikube. Al asociar minikube a `kubectl`, se configura el contexto de `kubectl` para que apunte al clúster de minikube, lo que permite ejecutar comandos como `kubectl get pods` o `kubectl apply` directamente en el clúster de minikube.

Verificar que el contexto de kubectl sea minikube:

```bash
$ kubectl config get-contexts

CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
          docker-desktop   docker-desktop   docker-desktop
*         minikube         minikube         minikube         default
```

Ya está seleccionado, pero si te tocara seleccionarlo, ejecuta la siguiente instrucción:

```bash
kubectl config use-context minikube
```

## Implementando un servidor nginx

NGINX es un servidor web/proxy inverso ligero y de alto rendimiento. Puede servir como un servidor web estático y dinámico, además de ser un servidor proxy inverso para balancear la carga de los servidores web de backend y proporcionar funcionalidades adicionales, como la autenticación, la compresión de datos y el almacenamiento en caché. NGINX es uno de los servidores web más populares y ampliamente utilizados en Internet.

Para levantar un contenedor con nginx, puedes utilizar el siguiente comando en la terminal:

```bash
$ kubectl run nginx --image=nginx
pod/nginx created
```

Este comando creará un nuevo deployment llamado nginx utilizando la imagen de Docker nginx. Para crear el deployment de nginx, podemos utilizar el siguiente comando:

```bash
$ kubectl create deployment nginx --image=nginx
deployment.apps/nginx created
```

Este comando creará un deployment con una sola réplica y la imagen de nginx. Luego, podemos exponer el deployment utilizando el siguiente comando:

```bash
$ kubectl expose deployment nginx --port=80 --type=NodePort
service/nginx exposed
```

Obteniendo la URL del servicio de nginx:

```bash
$ minikube service nginx --url

E0308 16:08:46.423561    7108 service_tunnel.go:66] error starting ssh tunnel: exec: "ssh": executable file not found in $PATH
http://127.0.0.1:46239
❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

El error que estás recibiendo indica que el binario ssh no está disponible en tu $PATH. Para solucionar esto, debes instalar el cliente SSH en tu sistema. En Debian y sistemas similares puedes hacerlo con el siguiente comando:

```bash
sudo apt-get install openssh-client -y
```

Una vez que hayas instalado el cliente SSH, intenta de nuevo la instrucción:

```bash
$ minikube service nginx --url
http://127.0.0.1:39901
❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

Bienvenido al contenedor que corre `nginx` desde Kubernetes montado en WSL con Docker Desktop.

![Bienvenido al contenedor que corre nginx desde Kubernetes montado en WSL con Docker Desktop](https://user-images.githubusercontent.com/7296281/223864271-79ace254-021d-4122-966c-2737d4883735.png)

## Gestionar pods y services

En Kubernetes, un pod es la unidad básica de implementación y se refiere a uno o más contenedores que se ejecutan en el mismo nodo y comparten el mismo espacio de red y almacenamiento. Los pods son escalables y son la unidad de implementación más pequeña y manejable.

Por otro lado, un servicio es un objeto de Kubernetes que define una política de acceso a un conjunto de pods. Los servicios permiten que los pods se comuniquen entre sí y con otros componentes de la aplicación en el clúster de Kubernetes, incluso si los pods se mueven o se escalan dinámicamente. Un servicio se puede exponer a través de diferentes tipos de protocolos de red, como TCP o UDP, y puede ser expuesto interna o externamente al clúster de Kubernetes.

Para ver los pods que están corriendo, puedes usar el siguiente comando:

```bash
$ kubectl get pods

NAME                     READY   STATUS    RESTARTS   AGE
nginx                    1/1     Running   0          16m
nginx-748c667d99-4gzjp   1/1     Running   0          15m
```

Para ver los servicios que están corriendo, puedes usar el siguiente comando:

```bash
$ kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        32m
nginx        NodePort    10.109.69.223   <none>        80:32330/TCP   16m
```

Para detener la ejecución de un pod, puedes usar el siguiente comando, reemplazando con el nombre del pod que deseas detener:

```bash
$ kubectl delete pod nginx
pod "nginx" deleted
```

Para detener la ejecución de un servicio, puedes usar el siguiente comando, reemplazando con el nombre del servicio que deseas detener:

```bash
$ kubectl delete service nginx
service "nginx" deleted
```

Ten en cuenta que al detener un pod o servicio, cualquier recurso que dependa de ellos también se detendrá.

## Estado de minikube

Te presento los diferentes estados en lo que podemos encontrar a minikube.

- Estado de minikube cuando está *running*.
- Estado de minikube cuando está *stopped*.
- Estado de minikube cuando Docker Desktop está cerrado.

Estado de minikube cuando está *running*:

```bash
$ minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Estado de minikube cuando está *stopped*:

```bash
# Se detiene minikube
$ minikube stop

✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.
```

```bash
$ minikube status

minikube
type: Control Plane
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Stopped
```

Estado de minikube detenido reflejado en Docker Desktop.

![Estado de minikube detenido reflejado en Docker Desktop](https://user-images.githubusercontent.com/7296281/223866376-29d9467d-b15b-4c82-9022-59d60ccd9c22.png)

Estado de minikube cuando Docker Desktop está cerrado:

```bash
$ minikube status

E0308 16:32:53.564727    8176 status.go:260] status error: host: state: unknown state "minikube": docker container inspect minikube --format={{.State.Status}}: exit status 1
stdout:

The command 'docker' could not be found in this WSL 2 distro.
We recommend to activate the WSL integration in Docker Desktop settings.

For details about using Docker Desktop with WSL 2, visit:

https://docs.docker.com/go/wsl2/

stderr:
E0308 16:32:53.564775    8176 status.go:263] The "minikube" host does not exist!
minikube
type: Control Plane
host: Nonexistent
kubelet: Nonexistent
apiserver: Nonexistent
kubeconfig: Nonexistent
```

Con solo levantar el Docker-Desktop y hacer un minikube start, vuelves a la acción.

## Desinstalar k8s

Para desinstalar Kubernetes, primero debemos desinstalar todos los componentes relacionados con Kubernetes. Aquí hay una lista de los paquetes que pueden estar instalados en diferentes sistemas operativos:

### Ubuntu/Debian:

```bash
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*
sudo apt-get autoremove
```

### CentOS/Fedora/RHEL:

```bash
sudo yum remove kubeadm kubectl kubelet kubernetes-cni kube*
```

### macOS:
```bash
brew uninstall kubernetes-cli kubernetes-helm
sudo rm /usr/local/bin/kubectl
```

Es importante tener en cuenta que desinstalar Kubernetes puede tener implicaciones en las aplicaciones que se están ejecutando en el clúster. Se recomienda hacer una copia de seguridad de los datos y tomar precauciones antes de desinstalar Kubernetes.

## Conclusión

En conclusión, la instalación y configuración de Kubernetes en un entorno de desarrollo es una habilidad esencial para cualquier desarrollador que desee probar y desplegar aplicaciones de forma eficiente y escalable en contenedores. En este artículo, hemos cubierto los pasos necesarios para instalar y configurar Kubernetes en WSL (Windows Subsystem for Linux) y Docker Desktop para distribuciones GNU/Linux. También hemos aprendido sobre los conceptos básicos de Kubernetes, como pods y servicios, que son fundamentales para comprender cómo funciona la orquestación de contenedores en Kubernetes. Esperamos que esta guía le haya resultado útil y le haya brindado una buena comprensión de los fundamentos de Kubernetes y su implementación en un entorno de desarrollo. ¡Ahora está listo para comenzar a trabajar con Kubernetes!

# Fuentes
 
- https://roadmap.sh/kubernetes
- https://www.crashell.com/estudio/implementando_kubernetes_en_wsl_y_docker_desktop

## Install from script bash

https://github.com/jersonmartinez/30-Days-Of-Kubernetes/blob/main/Days/01/install_kubernetes_minikube.sh

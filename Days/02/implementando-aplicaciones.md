- [Implementando aplicaciones](#implementando-aplicaciones)
  - [Addons de Kubernetes](#addons-de-kubernetes)
    - [Implementar un addon](#implementar-un-addon)
  - [Dashboard de Kubernetes](#dashboard-de-kubernetes)
- [Fuentes](#fuentes)

# Implementando aplicaciones

## Addons de Kubernetes

Los *addons* de Kubernetes son componentes que se pueden agregar a un clúster de Kubernetes para habilitar características adicionales, como la gestión de redes, el descubrimiento de servicios, el monitoreo y la administración de registros. Estos addons son implementados como Pods en el clúster y pueden ser habilitados o deshabilitados según sea necesario. Los addons son una forma de extender las funcionalidades del clúster y adaptarlas a las necesidades específicas de una aplicación o entorno.

### Implementar un addon

Para aplicar un addon en Kubernetes, primero debes asegurarte de que el addon que deseas usar esté habilitado en tu clúster. Puedes verificar los addons habilitados con el comando `minikube addons list` si estás usando Minikube. Luego, para habilitar un addon específico, puedes usar el comando `minikube addons enable <addon-name>`.

Por ejemplo, si deseas habilitar el addon metrics-server en Minikube, puedes ejecutar el siguiente comando:

```bash
minikube addons enable metrics-server
```

## Dashboard de Kubernetes

Listar los *addons* disponibles en el clúster de `minikube`.

```bash
minikube addons list
```

Habilita el *addon* `metrics-server` en una instalación de `minikube`, que permite la recolección y el análisis de métricas de recursos de los nodos y los `pods` en un clúster de Kubernetes.

```bash
$ minikube addons enable metrics-server

💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/metrics-server/metrics-server:v0.6.2
🌟  The 'metrics-server' addon is enabled
```

Habilita el *addon* del panel de control de Kubernetes (`Kubernetes Dashboard`) en `Minikube`, lo que permite acceder a una interfaz gráfica de usuario para administrar y monitorear los recursos de Kubernetes en el clúster.

```bash
$ minikube addons enable dashboard

💡  dashboard is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

        minikube addons enable metrics-server

🌟  The 'dashboard' addon is enabled
```

Para comprobar que los `addons`  o complementos han sido habilitados, se aplica un `minikube addons list`. 

```bash
$ minikube addons list

|-----------------------------|----------|--------------|--------------------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |           MAINTAINER           |
|-----------------------------|----------|--------------|--------------------------------|
| ambassador                  | minikube | disabled     | 3rd party (Ambassador)         |
| auto-pause                  | minikube | disabled     | Google                         |
| cloud-spanner               | minikube | disabled     | Google                         |
| csi-hostpath-driver         | minikube | disabled     | Kubernetes                     |
| dashboard                   | minikube | enabled ✅   | Kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | Kubernetes                     |
| efk                         | minikube | disabled     | 3rd party (Elastic)            |
| freshpod                    | minikube | disabled     | Google                         |
| gcp-auth                    | minikube | disabled     | Google                         |
| gvisor                      | minikube | disabled     | Google                         |
| headlamp                    | minikube | disabled     | 3rd party (kinvolk.io)         |
| helm-tiller                 | minikube | disabled     | 3rd party (Helm)               |
| inaccel                     | minikube | disabled     | 3rd party (InAccel             |
|                             |          |              | [info@inaccel.com])            |
| ingress                     | minikube | disabled     | Kubernetes                     |
| ingress-dns                 | minikube | disabled     | Google                         |
| istio                       | minikube | disabled     | 3rd party (Istio)              |
| istio-provisioner           | minikube | disabled     | 3rd party (Istio)              |
| kong                        | minikube | disabled     | 3rd party (Kong HQ)            |
| kubevirt                    | minikube | disabled     | 3rd party (KubeVirt)           |
| logviewer                   | minikube | disabled     | 3rd party (unknown)            |
| metallb                     | minikube | disabled     | 3rd party (MetalLB)            |
| metrics-server              | minikube | enabled ✅   | Kubernetes                     |
| nvidia-driver-installer     | minikube | disabled     | Google                         |
| nvidia-gpu-device-plugin    | minikube | disabled     | 3rd party (Nvidia)             |
| olm                         | minikube | disabled     | 3rd party (Operator Framework) |
| pod-security-policy         | minikube | disabled     | 3rd party (unknown)            |
| portainer                   | minikube | disabled     | 3rd party (Portainer.io)       |
| registry                    | minikube | disabled     | Google                         |
| registry-aliases            | minikube | disabled     | 3rd party (unknown)            |
| registry-creds              | minikube | disabled     | 3rd party (UPMC Enterprises)   |
| storage-provisioner         | minikube | enabled ✅   | Google                         |
| storage-provisioner-gluster | minikube | disabled     | 3rd party (Gluster)            |
| volumesnapshots             | minikube | disabled     | Kubernetes                     |
|-----------------------------|----------|--------------|--------------------------------|
```

La instrucción `minikube dashboard` se utiliza para abrir el panel de control de Kubernetes Dashboard en el navegador web predeterminado. Es una herramienta gráfica que proporciona una vista en tiempo real de los recursos de Kubernetes y puede ser utilizada para monitorizar y gestionar el clúster de Kubernetes desde una interfaz web.

```bash
$ minikube dashboard

🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:43663/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
👉  http://127.0.0.1:43663/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

Abrir uno de los enlaces: 

![imagen](https://user-images.githubusercontent.com/7296281/225211280-d1e0ffa6-ba0b-4b77-8a16-bf02ee1c99c2.png)

Con esto estás listo.

# Fuentes

Pueden encontrar mayor información en su página oficial: 

- https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/
- https://kubernetes.io/docs/concepts/
- https://roadmap.sh/kubernetes

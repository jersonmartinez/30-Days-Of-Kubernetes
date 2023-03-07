- [Introducción](#introducción)
  - [Kubernetes y k8s](#kubernetes-y-k8s)
  - [Componentes de Kubernetes](#componentes-de-kubernetes)
    - [Componente de Orquestación](#componente-de-orquestación)
  - [Componente de control de recursos](#componente-de-control-de-recursos)
    - [Componente de Planificación](#componente-de-planificación)
    - [Componente de Red](#componente-de-red)
    - [Agente de Kubernetes](#agente-de-kubernetes)
    - [Almacén de datos distribuído](#almacén-de-datos-distribuído)
  - [De servidores físicos a contenedores](#de-servidores-físicos-a-contenedores)
    - [Despliegue tradicional](#despliegue-tradicional)
    - [Despliegue virtualizado](#despliegue-virtualizado)
    - [Despliegue en contenedores](#despliegue-en-contenedores)
- [Fuentes y fuentes](#fuentes-y-fuentes)


# Introducción

Kubernetes es una plataforma de orquestación de contenedores de código abierto que automatiza la implementación, el escalado y la gestión de aplicaciones en contenedores. Fue desarrollado por Google y lanzado en 2014 como un proyecto de código abierto.

Kubernetes ofrece una manera eficiente de gestionar contenedores en grandes clústeres, permitiendo a los desarrolladores desplegar y gestionar aplicaciones en cualquier infraestructura de forma consistente. Con Kubernetes, los desarrolladores pueden definir cómo se deben ejecutar las aplicaciones en contenedores y Kubernetes se encarga de asignar recursos, escalar automáticamente y gestionar la disponibilidad de las aplicaciones.

Kubernetes se basa en una arquitectura cliente-servidor y consta de varios componentes, como el componente de orquestación (`kube-apiserver`), el componente de planificación (`kube-scheduler`), el componente de control de recursos (`kube-controller-manager`) y el componente de red (`kube-proxy`). Además, Kubernetes cuenta con una API que permite a los usuarios interactuar con los diferentes componentes de Kubernetes para gestionar aplicaciones en contenedores.

## Kubernetes y k8s

Kubernetes y k8s son lo mismo. "K8s" es simplemente una forma abreviada y más corta de escribir "Kubernetes". La "8" representa los 8 caracteres que faltan entre la "K" y la "s" en la palabra "Kubernetes".

La abreviatura `k8s` se utiliza a menudo en la comunidad de Kubernetes y en la documentación técnica de Kubernetes para ahorrar espacio y tiempo de escritura. Por lo tanto, `Kubernetes` y `k8s` se refieren a la misma plataforma de orquestación de contenedores de código abierto.

## Componentes de Kubernetes

Kubernetes consta de varios componentes que trabajan juntos para proporcionar una plataforma de orquestación de contenedores escalable y automatizada. Los componentes son los siguientes: 

- Componente de Orquestación (`kube-apiserver`)
- Componente de control de recursos (`kube-controller-manager`)
- Componente de Planificación (`kube-scheduler`)
- Componente de Red (`kube-proxy`)
- Agente de Kubernetes (`kubelet`)
- Almacén de datos distribuído (`etcd`)

### Componente de Orquestación

**kube-apiserver**: Es el componente de orquestación principal que expone la API de Kubernetes. Los usuarios y otros componentes interactúan con la API de k8s para realizar opraciones en el clúster.

## Componente de control de recursos

**kube-controller-manager**: Es el componente que se encarga de los procesos de control y gestión en el clúster. Los controladores del sistema, como el controlador de réplicas, el controlador de nodos y el controlador de servicios, son gestionados por el `kube-controller-manager`.

### Componente de Planificación

**kube-scheduler**: Es el componente que se encarga de programar los contenedores en los nodos del clúster en función de los requisitos de recursos y otras restricciones.

### Componente de Red

**kube-proxy**: Es el componente que gestiona el tráfico de red del clúster y se encarga de la configuración de la red para los servicios.

### Agente de Kubernetes

**kubelet**: Es el agente que se ejecuta en cada nodo del clúster y se comunica con el componente principal de Kubernetes para asegurar que los contenedores se estén ejecutando correctamente en el nodo.

### Almacén de datos distribuído

**etcd**: Es un almacén de datos distribuido y coherente que se utiliza para almacenar el estado del clúster de Kubernetes.

Además de estos componentes principales, hay otros componentes opcionales que se pueden utilizar según las necesidades, como los componentes de monitoreo, los sistemas de almacenamiento en la nube y los sistemas de gestión de logs. En conjunto, estos componentes permiten a Kubernetes gestionar y orquestar los contenedores de manera eficiente y escalable.

## De servidores físicos a contenedores

Con el tiempo vamos observando avances en la tecnología. Dichos avances en términos de carga y en el consumo de recursos, se ha ido acelerando de forma pronunciada. En la siguiente imagen se ilustra de forma comparativa el tiempo en el que estamos y lo que a día de hoy Kubernetes nos ofrece.

![De servidores físicos a contenedores](https://user-images.githubusercontent.com/7296281/223314955-325a58d2-af19-4530-a5df-ee0efbe5bb1f.png)

### Despliegue tradicional

Tenemos una aplicación a desplegar; dicha aplicación está teniendo mucho tráfico, ese tráfico se necesita repartir en más servidores, un conjunto (clúster) que desconocemos, debido a que no sabemos cómo es al escala de crecimiento en el tráfico, y aunque se puede monitorizar, es difícil predecirlo. Por ende, se invierte en un número estimado de servidores físicos, o bien, se consumen más recursos, haciendo que estos servidores sean verticales, aumentando la memoria, procesamiento y almacenamiento, e incluso, utilizando mayores segmentos de red. Esto no deja de ser una solución, pero no la más óptima para los temas que a todos nos interesa, sí, el tema financiero y también para que la aplicación se encuentre con alta disponibilidad.

### Despliegue virtualizado

La virtualización en sí, es tener un conjunto de componentes de software, como un sistema operativo funcionando encima de otro OS base, compartiendo los recursos que tiene el OS base, que dicho sea de paso, el OS base controla todo el hardware y este concede, de acuerdo a ciertas configuraciones, recursos para una máquina virtual.

Siguiente con el esquema anterior, al momento de mantener una aplicación, es posible crear un entorno en que tanto desarrollo como producción puedan tener el mismo software y levantar réplicas "similares" de componentes de software de una máquina virtual en otra. Lo interesante es que si tenemos mucho tráfico, es posible aplicar balanceo de carga, repartiendo solicitudes entre una máquina y otra; hacinedo que la distribución de dicho tráfico sea mejor que adquirir más hardware; sin olvidar que las máquinas virtuales también están corriendo sobre un único hardware o más, interconectadas en red. Sin duda, esta es una mejor opción que el despliegue tradicional.

### Despliegue en contenedores

Siguiendo el mismo esquema de mantener una aplicación con alta disponibilidad, se lleva a cabo un sistema de contenedores, que encapsula un conjunto de componentes virtualizados, sin ser una máquina virtual, sin ser un servidor físico, más bien, montado sobre un servidor físico, porque a fin de cuenta, todo tiene que correr sobre hardware. Entre las ventajas que podemos encontrar de utilizar contenedores, es la velocidad con la que puedes levantar entornos, tanto así que puedes gestionar contenedores utilizando pocos recursos, aplicar mayor distribución y dividir los componentes en pequeños servicios. 

# Fuentes y fuentes

Pueden encontrar mayor información en su página oficial: https://kubernetes.io/docs/concepts/overview/
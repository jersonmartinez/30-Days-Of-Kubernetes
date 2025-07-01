- [Introducción a Kubernetes](#introducción-a-kubernetes)
  - [Concepto](#concepto)
  - [Contenedores](#contenedores)
    - [Características de los contenedores](#características-de-los-contenedores)
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
  - [¿Por qué deberías usar Kubernetes?](#por-qué-deberías-usar-kubernetes)
    - [Características de Kubernetes](#características-de-kubernetes)
  - [Conceptos y terminologías alrededor de Kubernetes](#conceptos-y-terminologías-alrededor-de-kubernetes)
  - [Herramientas](#Herramientas)
    - [Minikube](#Minikube)
  - [Alternativas a Kubernetes](#alternativas-a-kubernetes)
- [Fuentes](#fuentes)

# Introducción a Kubernetes

## Concepto

Kubernetes es una plataforma de orquestación de contenedores de código abierto que automatiza la implementación, el escalado y la gestión de aplicaciones en contenedores. Fue desarrollado por Google y lanzado en 2014 como un proyecto de código abierto.

Kubernetes ofrece una manera eficiente de gestionar contenedores en grandes clústeres, permitiendo a los desarrolladores desplegar y gestionar aplicaciones en cualquier infraestructura de forma consistente. Con Kubernetes, los desarrolladores pueden definir cómo se deben ejecutar las aplicaciones en contenedores y Kubernetes se encarga de asignar recursos, escalar automáticamente y gestionar la disponibilidad de las aplicaciones.

Kubernetes se basa en una arquitectura cliente-servidor y consta de varios componentes, como el componente de orquestación (`kube-apiserver`), el componente de planificación (`kube-scheduler`), el componente de control de recursos (`kube-controller-manager`) y el componente de red (`kube-proxy`). Además, Kubernetes cuenta con una API que permite a los usuarios interactuar con los diferentes componentes de Kubernetes para gestionar aplicaciones en contenedores.

## Contenedores

Los contenedores son una tecnología de virtualización que permite que las aplicaciones se ejecuten en un entorno aislado y portátil. Un contenedor es una unidad de software que contiene todo lo necesario para que una aplicación se ejecute, incluyendo el código, las bibliotecas y las dependencias. Los contenedores se pueden crear a partir de una imagen de contenedor, que es una plantilla que contiene todo lo necesario para crear un contenedor.

A diferencia de la virtualización tradicional, donde cada máquina virtual tiene su propio sistema operativo completo, los contenedores comparten el mismo sistema operativo del host, lo que los hace más livianos y rápidos de crear y de mover. Los contenedores también ofrecen una mayor flexibilidad y portabilidad que la virtualización tradicional, lo que los hace ideales para el desarrollo de aplicaciones y la implementación en entornos de producción.

Los contenedores son ampliamente utilizados en la actualidad, y son una tecnología clave para la implementación de aplicaciones en la nube y la automatización de la entrega de software. Algunas de las plataformas de contenedores más populares incluyen Docker y Kubernetes.

### Características de los contenedores

A continuación se presentan algunas de las características más destacadas de los contenedores:

- **Portabilidad:** Los contenedores son altamente portátiles y se pueden mover fácilmente entre diferentes entornos de nube, sistemas operativos y plataformas de hardware.

- **Aislamiento:** Los contenedores ofrecen un alto nivel de aislamiento de recursos, lo que significa que pueden ejecutarse múltiples aplicaciones en un mismo host sin interferir entre sí.

- **Ligereza:** Los contenedores son ligeros y rápidos de crear y destruir, lo que los hace ideales para la implementación de aplicaciones en la nube y la automatización de la entrega de software.

- **Compartición de recursos:** Los contenedores comparten recursos con el sistema operativo del host y otros contenedores, lo que resulta en un uso más eficiente de los recursos y una mayor capacidad de escalado.

- **Escalabilidad:** Los contenedores pueden escalar horizontalmente de manera fácil y rápida, lo que permite agregar más recursos para manejar una carga de trabajo creciente.

- **Facilidad de gestión:** Los contenedores son fáciles de gestionar y actualizar, lo que reduce el tiempo de inactividad y los costos de mantenimiento.

- **Automatización:** Los contenedores se pueden integrar fácilmente con herramientas de automatización, como Kubernetes, para orquestar y administrar de manera eficiente los contenedores en múltiples hosts.


|   Características   |  Servidor físico  |  Máquina virtual  |  Contenedor  |
|---------------------|-------------------|-------------------|--------------|
| Virtualización      | No                | Sí                | Sí           |
| Sistema operativo   | Uno               | Varias            | Compartido   |
| Recursos            | Dedicados         | Asignados         | Compartidos  |
| Aislamiento         | Limitado          | Bueno             | Excelente    |
| Portabilidad        | No                | Sí                | Sí           |
| Tiempo de inicio    | Minutos           | Minutos           | Segundos     |
| Sobrecarga          | Baja              | Alta              | Baja         |
| Escalabilidad       | Limitada          | Buena             | Excelente    |
| Reducción de costes | No                | Sí                | Sí           


| Característica | Servidor físico | Máquina virtual | Contenedor |
|----------------|----------------|----------------|------------|
| Tecnología de virtualización | No está virtualizado | Virtualización completa | Virtualización a nivel de sistema operativo |
| Aislamiento | No hay aislamiento | Aislamiento completo | Aislamiento parcial |
| Sistema operativo | Se ejecuta directamente en el hardware | Se ejecuta en una capa de abstracción en la máquina virtual | Se ejecuta en el sistema operativo del host |
| Recursos | Recursos dedicados del hardware | Recursos compartidos con el host y otras máquinas virtuales | Recursos compartidos con el host y otros contenedores |
| Tamaño | Grande y pesado | Grande y pesado debido a la necesidad de un sistema operativo completo | Pequeño y ligero debido al uso compartido del sistema operativo |
| Creación | Requiere configuración y mantenimiento manual | Puede ser creado y clonado fácilmente | Puede ser creado y eliminado rápidamente |
| Portabilidad | No es portátil y no se puede mover fácilmente | Portátil y se puede mover a través de diferentes hosts y nubes | Portátil y se puede mover a través de diferentes hosts y nubes |
| Rendimiento | Alto rendimiento debido al acceso directo al hardware | Rendimiento moderado debido a la capa de virtualización adicional | Alto rendimiento debido a la falta de una capa de virtualización adicional |
| Reducción de costes | Mayor costo debido a la necesidad de comprar y mantener hardware dedicado | Reducción de costes debido al uso compartido de hardware y la consolidación de múltiples máquinas virtuales en un solo host | Mayor reducción de costes debido al uso compartido de recursos y la eliminación de la necesidad de un sistema operativo completo |
| Uso de recursos | Uso ineficiente de recursos debido a la necesidad de dedicar hardware a cada aplicación | Uso eficiente de recursos debido al uso compartido de hardware entre múltiples máquinas virtuales | Uso más eficiente de recursos debido al uso compartido de hardware y la eliminación de la necesidad de un sistema operativo completo |

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

## ¿Por qué deberías usar Kubernetes?

Kubernetes es útil porque puede:

- Simplificar la implementación y la gestión de aplicaciones en contenedores, lo que permite a los equipos de desarrollo y operaciones trabajar de manera más eficiente.
- Proporcionar alta disponibilidad y escalabilidad a las aplicaciones, lo que significa que pueden manejar cargas de trabajo más grandes sin interrupciones.
- Proporcionar una plataforma para implementar aplicaciones en múltiples nubes y entornos de infraestructura.

### Características de Kubernetes

Kubernetes es una plataforma de orquestación de contenedores altamente escalable y flexible, que ofrece una serie de características y beneficios únicos para los usuarios. Algunas de las principales características de Kubernetes son:

- **Orquestación de contenedores:** Kubernetes permite a los usuarios automatizar y administrar aplicaciones en contenedores, lo que simplifica la implementación y la gestión de aplicaciones.
- **Escalabilidad:** Kubernetes permite escalar aplicaciones en contenedores automáticamente, lo que permite manejar grandes cargas de trabajo sin interrupciones.
- **Alta disponibilidad:** Kubernetes ofrece un alto nivel de disponibilidad, lo que significa que las aplicaciones pueden seguir funcionando incluso si algunos nodos fallan.
- **Gestión de recursos:** Kubernetes permite a los usuarios gestionar eficazmente los recursos de la infraestructura, como el CPU, la memoria y el almacenamiento, lo que garantiza una utilización eficiente de los recursos.
- **Despliegue automático:** Kubernetes permite a los usuarios implementar aplicaciones en contenedores automáticamente, lo que simplifica el proceso de implementación y reduce el tiempo de inactividad.
- **Actualización y gestión de configuración:** Kubernetes permite a los usuarios actualizar y gestionar la configuración de las aplicaciones en tiempo real, lo que garantiza la consistencia de la configuración en todo el clúster.
- **Portabilidad:** Kubernetes es una plataforma portátil, lo que significa que puede utilizarse en una amplia variedad de entornos, incluyendo múltiples nubes y sistemas operativos.
- **Extensibilidad:** Kubernetes es altamente extensible, lo que permite a los usuarios personalizar la plataforma para satisfacer sus necesidades específicas.

En resumen, Kubernetes es una plataforma de orquestación de contenedores altamente escalable y flexible que ofrece una amplia gama de características y beneficios únicos para los usuarios, lo que la convierte en una herramienta esencial para la gestión eficiente de aplicaciones en contenedores.

## Conceptos y terminologías alrededor de Kubernetes

Algunos de los conceptos y terminologías clave de Kubernetes incluyen:

**Nodo (Node)**
Un nodo es una máquina virtual o física en la que se ejecutan los contenedores de Kubernetes. Cada nodo es administrado por el sistema operativo y tiene una dirección IP única.

**Clúster (Cluster)**
Un clúster de Kubernetes es un conjunto de nodos que trabajan juntos para ejecutar aplicaciones. El clúster administra la planificación de la ejecución de contenedores y la escalabilidad de los recursos.

**Pod**
Un pod es la unidad básica de implementación en Kubernetes. Un pod es un grupo de uno o más contenedores que comparten el mismo espacio de red y almacenamiento. Los pods son programados en los nodos y pueden ser escalados horizontalmente según sea necesario.

**Controlador (Controller)**
Un controlador es un componente de Kubernetes que gestiona la replicación y escalabilidad de los pods. Los controladores aseguran que se ejecute el número deseado de pods en el clúster y mantienen su estado.

**Servicio (Service)**
Un servicio es un conjunto de pods que ofrecen la misma funcionalidad y que pueden ser accedidos por otros servicios o usuarios en el clúster. Los servicios proporcionan una dirección IP estable y un nombre de DNS para acceder a los pods.

**Volúmenes (Volumes)**
Los volúmenes en Kubernetes proporcionan un mecanismo para almacenar y acceder a datos en un contenedor de manera persistente. Los volúmenes pueden ser compartidos entre varios pods y pueden ser de diferentes tipos, como disco, red o almacenamiento en la nube.

**Estado (Stateful)**
Un estado es un término que se refiere a la capacidad de un pod para mantener su estado incluso después de reiniciarse. Los pods con estado son útiles para aplicaciones que requieren almacenamiento persistente, como bases de datos.

**Namespace**
Un namespace es un espacio virtual en el que se pueden organizar y aislar recursos de Kubernetes. Los namespaces permiten a los equipos trabajar de forma independiente en diferentes proyectos o aplicaciones dentro del mismo clúster.

**YAML**
YAML es un lenguaje de marcado de datos que se utiliza para definir configuraciones y recursos de Kubernetes en forma de archivos legibles por humanos. Los archivos YAML se utilizan comúnmente para describir la configuración del clúster, como los pods, servicios y controladores.

**API**
La API de Kubernetes proporciona una interfaz para interactuar con el clúster de Kubernetes y gestionar los recursos. La API se utiliza para crear, modificar y eliminar objetos de Kubernetes, como pods, servicios y volúmenes.

**ReplicaSet**
ReplicaSet es un tipo de controlador en Kubernetes que garantiza que el número deseado de replicas de un pod estén en ejecución en todo momento. ReplicaSet también permite escalar el número de replicas de un pod en función de la demanda de la aplicación.

**Deployment**
Deployment es un tipo de controlador en Kubernetes que facilita la implementación y actualización de una aplicación. El deployment maneja la replicación y el control de versiones de los pods y proporciona una manera de hacer rollbacks en caso de fallos en las actualizaciones.

**Ingress**
Ingress es una API que expone servicios HTTP y HTTPS fuera del clúster de Kubernetes. El ingreso es utilizado para enrutar el tráfico entrante a diferentes servicios y pods, lo que permite la exposición de aplicaciones en línea.

**Secretos (Secrets)**
Los secretos en Kubernetes son objetos que almacenan información sensible, como contraseñas, claves de API y certificados de TLS. Los secretos se almacenan de forma cifrada y se pueden utilizar en los pods para proporcionar acceso seguro a los recursos.

**ConfigMap**
ConfigMap es un objeto de Kubernetes que almacena datos de configuración en forma de pares clave-valor. ConfigMap se utiliza para separar la configuración de la aplicación de la imagen de contenedor, lo que permite la modificación de la configuración sin tener que volver a crear la imagen del contenedor.

**Helm**
Helm es un gestor de paquetes para Kubernetes que simplifica la gestión de aplicaciones. Helm proporciona un conjunto de herramientas para crear, compartir e instalar paquetes de aplicaciones en un clúster de Kubernetes.

**Taints y Tolerations**
Taints y Tolerations son mecanismos de Kubernetes para evitar que los pods se programen en nodos específicos o para permitir que los pods se programen en nodos específicos. Taints se aplican a los nodos para restringir la programación de los pods, mientras que las tolerancias se aplican a los pods para permitir la programación en nodos con ciertos taints.

**Horizontal Pod Autoscaler (HPA)**
HPA es un controlador de Kubernetes que automáticamente escala el número de replicas de un pod en función de la demanda de la aplicación. HPA utiliza métricas como el uso de la CPU y la memoria para determinar cuándo escalar los pods.

Estos son solo algunos de los conceptos y terminologías clave de Kubernetes. La plataforma ofrece una amplia variedad de herramientas y recursos para administrar y orquestar contenedores de aplicaciones en entornos de producción.

## Herramientas

### Minikube
Minikube es uno de los métodos más fáciles, flexibles y populares para ejecutar un clúster local Kubernetes todo-en-uno o multi-nodo, aislado por Máquinas Virtuales (VM) o Contenedores, ejecutados directamente en nuestras estaciones de trabajo. Minikube es la herramienta responsable de la instalación de los componentes de Kubernetes, el arranque del clúster y su desmantelamiento cuando ya no es necesario. Incluye características adicionales destinadas a facilitar la interacción del usuario con el clúster Kubernetes, pero no obstante, inicializa para nosotros un clúster Kubernetes completamente funcional, no de producción, extremadamente conveniente para fines de aprendizaje. Minikube se puede instalar en macOS nativo, Windows y muchas distribuciones de Linux.

**¿Qué es Minikube?**
Minikube es uno de los métodos más fáciles, flexibles y populares para ejecutar un clúster Kubernetes local todo-en-uno o multinodo directamente en nuestras estaciones de trabajo locales. Se instala y ejecuta en cualquier SO nativo como Linux, macOS o Windows. Sin embargo, con el fin de aprovechar al máximo todas las características que Minikube tiene para ofrecer, un Type-2 Hypervisor o un Container Runtime debe ser instalado en la estación de trabajo local, para ejecutarse en conjunto con Minikube. El papel del hipervisor o del tiempo de ejecución del contenedor es ofrecer una infraestructura aislada para los componentes del clúster Minikube Kubernetes, que sea fácilmente reproducible, fácil de usar y desmontar. Este aislamiento de los componentes del clúster de nuestro entorno diario garantiza que, una vez que ya no sean necesarios, los componentes de Minikube se puedan eliminar de forma segura sin dejar cambios de configuración en nuestra estación de trabajo y, por lo tanto, sin dejar rastro de su existencia. Esto no significa, sin embargo, que seamos responsables del aprovisionamiento de cualquier VM o contenedor con sistemas operativos invitados con la ayuda del hipervisor o del tiempo de ejecución del contenedor. Minikube incluye los adaptadores necesarios para interactuar directamente con el software de aislamiento elegido para construir toda su infraestructura siempre y cuando el Type-2 Hypervisor o el Container Runtime estén instalados en nuestra estación de trabajo.

Minikube está construido sobre las capacidades de la librería libmachine originalmente diseñada por Docker para construir hosts contenedores de Máquinas Virtuales sobre cualquier infraestructura física. Con el tiempo Minikube se hizo muy flexible, soportando varios hipervisores y tiempos de ejecución de contenedores, dependiendo del SO nativo de la estación de trabajo anfitriona.

Para aquellos que se sientan más aventureros, Minikube se puede instalar sin un software de aislamiento, en bare-metal, lo que puede resultar en cambios permanentes de configuración en el sistema operativo host. Para evitar estos cambios permanentes de configuración, una segunda forma de aislamiento se puede lograr mediante la instalación de Minikube dentro de una máquina virtual aprovisionada con un hipervisor de tipo 2 de su elección, y un sistema operativo invitado de escritorio de su elección (con interfaz gráfica de usuario habilitada). Como resultado, cuando se instala dentro de una máquina virtual, Minikube terminará haciendo cambios de configuración en el entorno invitado, todavía aislado de la estación de trabajo host. Por lo tanto, ahora tenemos dos métodos distintos para aislar el entorno Minikube de nuestra estación de trabajo host.

El software de aislamiento puede ser especificado por el usuario con la opción `--driver`, de lo contrario Minikube tratará de encontrar un método preferido para el SO anfitrión de la estación de trabajo.

Una vez decidido el método de aislamiento, el siguiente paso es determinar el número necesario de nodos de clúster Kubernetes, y sus tamaños en términos de CPU, memoria y espacio en disco. Minikube invoca al hipervisor de su elección para aprovisionar la(s) VM(s) de infraestructura que alojará(n) el(los) nodo(s) de cluster Kubernetes, o el runtime de su elección para ejecutar el(los) contenedor(es) de infraestructura que alojará(n) el(los) nodo(s) de cluster. Tenga en cuenta que Minikube ahora soporta clusters todo-en-uno de un solo nodo y de múltiples nodos. Independientemente del método de aislamiento y de los tamaños esperados del clúster y de los nodos, un clúster local Minikube Kubernetes se verá afectado y/o limitado en última instancia por los recursos físicos de la estación de trabajo anfitriona. Tenemos que ser conscientes de las necesidades del sistema operativo anfitrión y cualquier utilidad que pueda estar ejecutando, a continuación, las necesidades del hipervisor o el tiempo de ejecución del contenedor, y, finalmente, los recursos restantes que se pueden asignar a nuestro clúster Kubernetes. Para un entorno de aprendizaje las recomendaciones son que un nodo Kubernetes tiene 2 núcleos de CPU (o CPUs virtuales) como mínimo, al menos 2 GB de memoria RAM (con 4 - 8 GB de RAM recomendado para un uso óptimo), y 20 + GB de espacio de almacenamiento en disco. Al migrar a un clúster de producción más grande y dinámico, estos valores de recursos deben ajustarse en consecuencia. También se espera que los nodos Kubernetes tengan acceso a Internet para actualizaciones de software, descargas de imágenes de contenedores y accesibilidad de clientes.

## Alternativas a Kubernetes

Aunque Kubernetes es la plataforma de orquestación de contenedores más popular y ampliamente utilizada en la actualidad, existen varias alternativas disponibles para aquellos que buscan opciones diferentes. Algunas de las alternativas a Kubernetes incluyen:

- **Docker Swarm:** Es una plataforma de orquestación de contenedores integrada en el motor de Docker. Swarm es más fácil de implementar y mantener que Kubernetes, lo que lo hace una buena opción para equipos pequeños o proyectos más simples.

- **Apache Mesos:** Es una plataforma de orquestación de contenedores que ofrece una mayor flexibilidad y escalabilidad que Kubernetes. Mesos permite que los recursos del clúster se compartan entre varias aplicaciones y frameworks, lo que lo hace una buena opción para empresas que ejecutan múltiples aplicaciones en su infraestructura.

- **Nomad:** Es una plataforma de orquestación de contenedores desarrollada por HashiCorp. Nomad se centra en la simplicidad y la facilidad de uso, lo que lo hace una buena opción para proyectos más pequeños y para equipos que buscan una alternativa más ligera a Kubernetes.

- **Amazon ECS:** Es un servicio de orquestación de contenedores ofrecido por Amazon Web Services (AWS). ECS es fácil de usar y está completamente integrado con otros servicios de AWS, lo que lo hace una buena opción para empresas que utilizan AWS para su infraestructura.

- **OpenShift:** Es una plataforma de orquestación de contenedores de código abierto desarrollada por Red Hat. OpenShift utiliza Kubernetes como base y proporciona una capa de gestión de aplicaciones más fácil de usar, lo que lo hace una buena opción para empresas que buscan una solución todo en uno.

- **Google Cloud Run:** Es un servicio de orquestación de contenedores sin servidor ofrecido por Google Cloud. Cloud Run permite que los contenedores se ejecuten en un entorno completamente administrado y escalado automáticamente, lo que lo hace una buena opción para aplicaciones sin servidor y microservicios.

Estas son solo algunas de las alternativas a Kubernetes disponibles en el mercado. Es importante evaluar las necesidades de la organización y seleccionar la plataforma de orquestación de contenedores que mejor se adapte a ellas.

## 🎯 Próximos Pasos

1. **Instalar Kubernetes localmente** (Día 1)
   - Minikube para desarrollo
   - Docker Desktop
   - Kind (Kubernetes in Docker)

2. **Explorar kubectl** (Día 2)
   - Comandos básicos
   - Gestión de recursos
   - Debugging

3. **Crear tu primera aplicación** (Día 3)
   - Pods y Deployments
   - Services y Networking
   - ConfigMaps y Secrets

## 🛠️ Scripts y Herramientas

Para comenzar tu práctica inmediatamente, ejecuta:

```bash
# Demostración interactiva de conceptos
cd Days/00/scripts/
chmod +x kubernetes-overview.sh
./kubernetes-overview.sh
```

Este script incluye:
- ✅ Comparativa práctica: Servidores físicos vs VMs vs Contenedores
- ✅ Demostración de conceptos básicos de Kubernetes
- ✅ Self-healing automático en acción
- ✅ Escalamiento horizontal dinámico
- ✅ Rolling updates sin downtime
- ✅ Gestión de configuración con ConfigMaps y Secrets

# Fuentes

Pueden encontrar mayor información en su página oficial: 
- https://kubernetes.io/docs/concepts/
- https://kubernetes.io/docs/concepts/overview/
- https://roadmap.sh/kubernetes
- https://minikube.sigs.k8s.io/docs/start/
# Migraciones de esquemas de Bases de Datos

El plano de los datos en el mundo de contenedores siempre fue relegado al último
plano. En un principio, esto fue porque las primeras cargas de trabajo que se
desplegaban en clusters de contenedores eran aplicaciones sin estado y por
tanto, muy fácilmente reinstanciables en cualquier nodo del cluster.

Cuando se desarrollan aplicaciones que dependen de un motor relacional, no
debemos dejar de pensar en cómo es que se versionan los cambios que deben
aplicarse a la base de datos, por ejemplo, si hay que actualizar el producto, de que forma poder determinar qué parche debe estar
aplicado en una versión de código determinada. Si bien el uso de [schema
migrations](https://en.wikipedia.org/wiki/Schema_migration) es muy útil en
ambientes de desarrollo, para poder avanzar o retroceder en el tiempo la
estructura de una base de datos, en producción tiene sus beneficios a costa de
algunas restricciones o consideraciones que no deben obviarse:

Al avanzar una versión de producto, es posible que sea necesario aplicar un
  parche a la base de datos. Entonces debemos considerar que si trabajamos en
  kuberentes, ese despliegue puede tener una escala mayor a 1 y una estrategia de
  [rolling update](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy),
  por lo que podrían darse las siguientes situaciones que deberiamos considerar:
  
* Durante el upgrade, algunos pods usarán la nueva versión y otros la vieja.
* Varios pods nuevos podrían iniciar de forma simultánea.
* Al degradar una versión de producto, la base de datos puede quedar con un
  parche aplicado que no debe interferir con las viejas versiones de pods.

De lo antes mencionado, vemos que los parches pueden utilizar migraciones que
ofrecen los frameworks de desarrollo, pero incluso existiendo la herramienta,
debe considerarse de qué forma se aplicará la misma:

* No debe realizarse migraciones destructivas. Si se elimina físicamente una
  columna de una tabla, probablemente las versiones viejas de producto que
  durante el upgrade quedan funcionales podrían comenzar a fallar. Se recomienda
  realizar modificaciones lógicas.
* Los cambios siempre deben pensarse compatibles entre versiones inmediatas.
  Esto debe permitir el funcionamiento de nuevos modelos de datos con versiones
  inmediatamente anteriores y viceversa.

Con las premisas antes mencionadas, surge además el problema del momento y forma
de aplicar las migraciones. Considerando que el despliegue podría estar
escalado a más de una instancia, entonces podrían aparecer simultáneamente varias
versiones nuevas de producto. Debido que frecuentemente se utilizan
[**initContainers**](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
para aplicar las migraciones, queremos acá hacer un paréntesis para analizar
este escenario. Si se da situación entonces de un **Deployment** con escala
mayor a uno, probablemente varios pods (el 25% por defecto), arrancarán en
simultáneo. Podría suceder que este inicio ejecute entonces las mismas
migraciones de forma simultánea, llevando la base de datos a algún estado no
deseado. Por esta razón, creemos que el uso de initContainers para correr las
migraciones es un **antipatrón**.

Proponemos entonces, utilizar una característica de Helm, que permite manipular
estos escenarios de una forma más ordenada. Es a través de los [Helm Chart hooks](https://helm.sh/docs/topics/charts_hooks/).
Con ellos, podemos crear manifiestos durante etapas propias del despliegue,
previas y posteriores a los eventos de install, delete, upgrade y rollback. De
esta forma, podemos utilizar un pre-install y pre-upgrade hook para disparar un
Job que corra las migraciones una única vez, antes de realizar el despliegue. Si
el Job termina de forma correcta, se procederá entonces con el despliegue. Sino,
se cancelará. Por esta razón, creemos que el uso de **Helm Chart Hooks es un
patrón** a considerar para aplicar migraciones de bases de datos.

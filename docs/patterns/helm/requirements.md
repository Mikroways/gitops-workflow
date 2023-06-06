# Requerimientos de un despliegue

Como hemos mencionado anteriormente, Helm soporta dependencias. Entonces, surge
la pregunta:
¿por qué no usar dependencias para instalar los requerimientos de un chart? El
inconveniente radica en que el término "requerimientos" es bastante amplio, y
por lo tanto podría generar confusión en relación al contexto especifico al que
nos referimos en esta sección.

Las dependencias de un Helm Chart se instalan en el mismo momento que los
manifiestos del Chart que declara dichas dependencias. Todo se instala de forma
simultánea, por lo que no existe un orden de prioridades entre esos manifiestos.
Un ejemplo claro del tipo de requerimientos al que nos referimos aquí sería una
base de datos que debe existir previo al despliegue del chart. Si aplicamos el
**_patrón de usar un Helm Chart hook_** para correr las migraciones de la base
de datos, este hook será de **pre-install** y **pre-upgrade**. El problema surge
en el **pre-install**, ya que antes de instalar el Chart, intentará correr un
Job que conecte con la base de datos. Si la base de datos es una dependencia, no
se instalará hasta que el _Job del Hook no finalice exitosamente_. Sin embargo,
este hook siempre fallará si no hay base de datos a la que conectarse.

Este es un ejemplo de un requerimiento que no podemos resolver dentro del mismo
chart. Debe existir un **momento previo donde desplegar los requerimientos**.
Con las herramientas consideradas por este marco de trabajo, no hay un patrón
que podamos recomendar, porque ninguna nos permite establecer prioridades u
orden de los despliegues. **Proponemos una [solución basada en una serie de
charts](https://github.com/Mikroways/argo-gitops-flow) que resuelven los
requerimientos propios de un despliegue basado en GitOps**. De esta manera se
separan los requerimientos en su propio path, y tenemos mayor control sobre los
mismos.

Además del ejemplo de la base de datos, muchas veces aparecen varios
requerimientos más, como ser [backing services](https://12factor.net/es/backing-services).
Otro ejemplo, es el de los [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/),
que deben existir porque los charts apuntan a un secreto que debe existir
previamente en el namespace del despliegue.

!!! info
    Todos estos escenarios son considerados por este marco.

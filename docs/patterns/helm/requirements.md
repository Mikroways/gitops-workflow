# Requerimientos de un despliegue

Como ya mencionamos en otras secciones, Helm soporta dependencias. Entonces, por
qué no usar dependencias para instalar los requerimientos de un chart. El
problema, es que el término requerimientos es un tanto amplio, y por tanto puede
confundirse el contexto al que queremos mencionar en este apartado.

Las dependencias de un Helm Chart, se instalan en el mismo momento que se
instalan los manifiestos del Chart que declara esas dependencias. Todo es
instalado de forma simultánea y por tanto, no hay un orden de prioridades entre
esos manifiestos. Por tanto, un claro ejemplo del tipo de requerimientos al que
hacemos mención aquí, sería la base de datos que debe existir previo al
despliegue del chart. Si estamos aplicando el **_patrón de usar un Helm
Chart hook_** para correr las migraciones de la base de datos, este hook será de
**pre-install** y **pre-upgrade**. El problema surge con el **pre-install**,
porque antes de instalar el Chart tratará de correr un Job que conecte con la
base de datos. Si la base de datos es una dependencia, no se instalará hasta que
el _Job del Hook no termine de forma exitosa_. Pero este hook siempre fallará si
no hay base de datos a la que conectar. 

Este es un ejemplo de un requerimiento, que no podemos resolver con un mismo
chart. Debe existir un **momento previo donde desplegar los requerimientos**.
Con las herramientas consideradas por este marco de trabajo, no hay un patrón
que podamos recomendar, porque ninguna nos permite establecer prioridades u
orden de los despliegues. Así es como en **este marco proponemos una [solución
basada en una serie de charts]() que resuelven los requerimientos propios de un
despliegue basado en GitOps**.

Además del ejemplo de la base de datos, muchas veces aparecen varios
requerimientos más, como ser [backing services](https://12factor.net/es/backing-services).
Otro ejemplo, es el de los [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/),
que deben existir porque los charts apuntan a un secreto que debe existir
previamente en el namespace del despliegue.

!!! info
    Todos estos escenarios son considerados por este marco.

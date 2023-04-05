# Una o varias aplicaciones en un Chart

Cuando empaquetamos una aplicación dentro de un Helm Chart, la arquitectura de
la misma puede ser más amplia que la propia aplicación: por ejemplo, puede
ser un backend desarrollado en Python y un frontend en React o Angular. Muchas
veces, en estos escenarios nos vemos tentados a empaquetar tanto backend como
frontend en un mismo chart de Helm. La pregunta entonces nos motiva a investigar
qué sería más adecuado, unificar todo en un chart o utilizar diferentes charts
para cada componente.

Cuando trabajamos con Git aparece una incógnita parecida: monorepo o un repo por
aplicación. Y la respuesta correcta depende de cuán aplicados queremos estar
respecto de los 12 factores, que apuntan a que cada applicación tenga su repo, y
con las emergentes arquitecturas de  microservicios además de las restricciones
impuestas por nuestra organización.

En línea con los 12 factores, el primer punto, [**código base**](https://12factor.net/es/codebase),
indica que existe una relación uno a uno entre el código base y una aplicación,
y que este debe ser versionado en un sistema de control de versiones como git.
Apuntamos a que cada aplicación tenga un repositorio en el cual podemos ademas,
versionar los artefactos relacionados, como sean los charts y herramientas que
facilitan su workflow. En relación a esto, los pipelines de CI/CD cada vez son
más utilizados y sus definiciones se versionan junto con el código de la
aplicación. Estos pipelines permiten testear, buildear y disponibilizar los
entregables. Proponemos entonces, agregar además al código base, los charts y
los pipelines de CI/CD para construir los mismos, de modo que los despliegues de
la aplicación queden autocontenidos con los fuentes.

Respecto al punto 5 de los 12 factores, [**construir, distribuir, ejecutar**](https://12factor.net/es/build-release-run),
no se estipula de qué forma se implementa, salvo por un ejemplo basado en
[capistrano](https://capistranorb.com/) que data del momento en que los 12
factores se crearon. Hoy día, se han adoptado los contenedores como medio de
distribución y ejecución. Así es como los pipelines mencionados en el párrafo
anterior, construyen y disponibilizan artefactos, y a su vez imágenes OCI.
Proponemos además, agregar el release de los charts como parte de este inciso, a
fin de proveer artefactos, imágenes OCI y ahora, el empaquetado de un despliegue
en forma de Helm Charts, listo para ser utilizado en clusters Kubernetes.

Creemos importante además, mencionar un ejemplo de Helm Charts almacenados en
repositorios independientes del de las propias aplicaciones. Esto fue lo que
sucedió con el [repositorio por defecto empleado en Helm v2](https://github.com/helm/charts).
Este repositorio fue deprecado por las dificultades en su mantenimiento. Pueden
leerse las razones directamente desde el repositorio e incluso desde el [Blog de
Helm](https://helm.sh/blog/charts-repo-deprecation/).

## Composición de Charts

Helm ha evolucionado en los últimos tiempos, y de ser una herramienta de
empaquetado con soporte de templating de manifiestos, a evolucionado con la
incorporación de [dependencias](https://helm.sh/docs/helm/helm_dependency/) y
[librerías](https://helm.sh/docs/topics/library_charts/).
Estos últimos puntos promueven la creación de Charts menos voluminosos, dado que
permiten compartir código y ofrecen Charts más fáciles de mantener por aplicar
[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

## Conclusiones

Por todas las razones antes expuestas, **consideramos conveniente el
versionado de Helm Charts junto con el código base de las aplicaciones**. Además,
su construcción y distribución al igual que sucede con la aplicación misma
usando repositorios de charts o registries OCI.

# Ambientes de despliegue

El término ambiente recibe varias connotaciones, sobre todo en el ámbito del
despliegue de aplicaciones. Por ello, queremos acotar su significado para
nuestro marco de trabajo.

Comenzamos por asumir que estamos trabajando en un cluster Kubernetes, por lo
que un ambiente considerará:

* Un namespace en un cluster de kubernetes
* En el namespace se desplegará una solución de software que no se corresponde
  con una única aplicación sino con varias aplicaciones que deben interactuar
  entre sí:
  * Cada aplicación tendrá un chart propio e independiente del resto.
  * Algunos charts desplegarán requerimientos que deben estar disponibles
      previo al despliegue de nuestras componentes.

Pero entonces, un ambiente sigue siendo un conjunto de manifiestos, y por lo tanto
**debería** poder ser descripto **declarativamente** y manipularse utilizando
**GitOps**. Y es aquí donde aparece una separación de roles y sus respectivos
accesos, que creemos
importante expresar y considerar:

* La creación de un nuevo ambiente es reponsabilidad de un rol diferencial.
  Seguramente sea el área de operaciones, pero no debe ser el mismo rol que
  podrá gestionar los despliegues del ambiente.
  * Este rol además, en ambientes multicluster, debe determinar en cuál de los
     clusters se desplegará.
* Los recursos asignados a un ambiente se discuten entre varios roles:
  operaciones, arquitectura, desarrollo y seguridad. Estos recursos deben
  considerar:
  * Las necesidades de memoria y CPU para el adecuado funcionamiento.
  * La escalabilidad mínima y máxima de cada carga de trabajo.
  * El upgrade, que demandará por un momento un aumento de los recursos que se
      suelen emplear.
  * Cantidad de storage necesario.
* Desde la perspectiva de seguridad, tanto personal de ese área, como desarrollo
  y operaciones deberán considerar qué Network Policies deben aplicarse al
  ambiente, tanto para el egreso, como ingreso de tráfico.

Dejando aclarado entonces los conceptos detrás de un ambiente de despliegue,
podemos proceder con algunos patrones importantes.

## Restricciones para el namespace

Kubernetes provee políticas listas para su aplicación cualquiera sea el
cluster:

* [**Resource Quotas**](https://kubernetes.io/docs/concepts/policy/resource-quotas/):
  nos permiten acotar la cantidad de recursos empleados por un namespace.
  Respecto a CPU y memoria, es posible limitar la cantidad requerida, como así
  también la cantidad sobre los límites. Además, permite restringir otros
  recursos tales como cantidad de PVC, servicios, etc. El uso de esta política
  es un **patrón aconsejable** dado que evita el agotamiento de recursos,
  limitando y obligando a cada equipo a estimar qué recursos son necesarios para
  el despliegue.
* [**Limit Ranges**](https://kubernetes.io/docs/concepts/policy/limit-range/):
  con esta política, aquellos contenedores que no establecen cuántos recursos
  requieren o limitan en sus propios manifiestos, heredaran los limites
  establecidos en el namespace. Estos contenedores serán modificados al ser
  creados en el namespace asociándoles una cantidad establecida de requerimiento
  y límites de CPU y memoria. Al combinar Limit Ranges con Resource Quotas
  podemos establecer un equilibrio saludable para la ejecución de cargas de
  trabajo en cualquier cluster. Por esta razón consideramos esta política un
  **patrón recomendable**.

En aquellos clusters con un
[CNI](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
 que soporte [**Network Policies**](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
proponemos su adopción como otro **patrón aconsejable**. Limitar el ingreso y
egreso de tráfico hacia y desde un namespace permite tener un mejor control de
seguridad en caso del compromiso de algún contenedor.

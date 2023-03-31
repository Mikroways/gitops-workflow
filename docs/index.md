# Introducción

Este [marco de trabajo](./framework) fue desarrollado por [Mikroways](https://mikroways.net)
con el fin de unificar la forma en que se implementa **GitOps** en el despliegue
de aplicaciones en uno o varios clusters de [kubernetes](https://kubernetes.io/).

El propósito detrás del marco de trabajo no es el de imponer un único modo de
trabajo, sino el de identificar una serie de [(anti) patrones](./patterns) que
aparecen recurrentemente en escenarios diferentes.

A su vez, proponemos por medio de [ejemplos](https://github.com/mikroways/argo-gitops-demo-example),
qué configuraciones y cómo aplicar aquellas prácticas descriptas en este
marco, permitiendo replicar una implementación pura de GitOps de forma segura.

## Qué es GitOps

El término GitOps, surge en el año 2017 como __buzzy word__ gracias a
[WaveWorks](https://www.weave.works/). En su blog, existe un post muy claro
acerca de la [historia de
GitOps](https://www.weave.works/blog/the-history-of-gitops).

Lo que podemos afirmar acerca de GitOps es:

* Se utiliza Git como fuente de verdad principal de lo que se aplica en la
  infraestructura. Esto significa que toda la infraestructura puede ser
  versionada, auditada y fácilmente revertida si es necesario, garantizando
  implementaciones consistentes y reproducibles. Permite ágil recuperación ante
  errores. Se versiona la configuración y estado de la infraestructura canónica.
* La evolución de las plataformas de Git y su integración con pipelines que
  permiten ejecutar acciones arbitrarias, extienden las posibilidades de aplicar
  GitOps a varios escenarios. Por ejemplo, utilizar infraestructura como código
  (con herramientas como Chef, Ansible, Puppet, Terraform, etc) ante cada cambio
  en git.
* Sin embargo, donde mejor aplica GitOps es cuando se utilizan lenguajes
  declarativos para impactar en la infraestrctura (Infraestructura como Datos).
  Este es el caso de Kubernetes, dado que los manifiestos son una representación
  de la intención. Luego el cluster llevará al estado deseado la infraestructura a
  través de controladores que convergen al satisfacer los manifiestos.

## Alcance

El concepto de GitOps es tan amplio que proponemos limitar el alcance del
actual procedimiento, al despliegue de aplicaciones que son desarrolladas por
la propia empresa u organismo.

!!! warning
    El presente documento, debe considerar el despliegue de cargas de trabajo en
    un cluster, y no ser considerado para el despliegue de servicios esenciales
    dentro de un cluster de Kubernetes. Por ejemplo, no consideramos aplicable
    este marco de trabajo para instalar servicios como ingress controllers,
    operadores de kubernetes, etc.

Estas aplicaciones, en el mejor de los casos se desarrollan aplicando los [12 factores](https://12factor.net/).
Pero las aplicaciones modernas, ya no constan de un único despliegue, porque
ya no son monolíticas sino que constan de varios servicios. Podemos dar como
ejemplo arquitecturas de microservicios o simplemente las típicas aplicaciones
frontend de tipo [SPA](https://en.wikipedia.org/wiki/Single-page_application)
que consumen una o más APIs desde uno o varios backends. Ambas componentes
(frontend y backend) posiblemente sean desarrolladas por el mismo equipo, aunque
podría no ser el caso.

Entonces cuando hagamos referencia a un despliegue con GitOps, probablemente
estemos considerando varias aplicaciones, como es el caso de los
microservicios, aplicaciones SPA, o varias componentes que cooperan de alguna
forma.

Con estas precondiciones, el alcance de este marco corresponde al despliegue de
ambientes usando GitOps, donde este despliegue considera varias componentes que
hacen funcional a la infraestructura de ese ambiente.

## ¿Cómo implementar el marco de trabajo?

Las posibilidades de implementar GitOps en kubernetes son varias. Sin embargo,
hay productos que se han afianzado más que otros, y este hecho puede ser
fácilmente visible observando [los proyectos graduados de la
CNCF](https://landscape.cncf.io/card-mode?project=graduated). Si bien con el
pasar del tiempo, podremos extender el presente documento a nuevas herramientas,
actualmente comenzaremos por acotar el mismo a las siguientes:

* **[ArgoCD](https://argo-cd.readthedocs.io/en/stable/):** utilizaremos
  [aplicaciones](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications),
  [proyectos](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)
  y [applicationsets](https://argocd-applicationset.readthedocs.io/en/stable/)
  para el despliegue continuo.
* **[Helm charts](https://helm.sh/):** como empaquetador templatizado de cada
  aplicación.
* **[Helm Secrets](https://github.com/jkroepke/helm-secrets):** un plugin de
  helm que nos permitirá cifrar valores sensibles usando [sops](https://github.com/mozilla/sops).

El marco de trabajo no explicará como usar las herramientas dado que cada una
tiene una documentación clara y con ejemplos propios. Nuestro aporte es el de
ejemplificar cómo es la integración de ellas, como así también la de enunciar 
(anti) patrones detectados y documentar qué solución ofrecemos en cada caso.

## ¿Qué ofrece el marco de trabajo con GitOps?

* Describe (anti) patrones con cada herramienta utilizada.
* Contempla escenarios muy diferentes, habiendo sido aplicado en clientes con
  estructuras  y necesidades distintas.
* Permite identificar y describir cómo implementar distintas etapas del proceso
  de despliegue, como por ejemplo:
    * Crear ambientes de forma declarativa.
    * Crear un proyecto en ArgoCD exclusivo para el ambiente donde se acotan los
      permisos usando [RBAC](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/).
    * Considerar el despliegue de aquellas componentes que se consideran
      requerimientos para nuestro ambiente usando GitOps. Esto significa, poder
      disponer de una serie de componentes listos para que nuestro ambiente
      utilice al momento de desplegar sus componentes.
    * Despliegue de aplicaciones usando GitOps. Este despliegue considera las
      componentes propias de nuestro despliegue, asumiendo existen y se cumplen
      los requisitos que eventualmente son necesasios.
* Soporte de Multicluster.

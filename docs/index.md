# Objetivo

Este marco de trabajo fue desarrollado por [Mikroways](https://mikroways.net)
con el fin de unificar la forma en que se implementa **GitOps** en el despliegue
de aplicaciones en uno o varios clusters de [kubernetes](https://kubernetes.io/).

El propósito detrás del marco de trabajo no es el de imponer un único modo de
trabajo, sino el de identificar una serie de patrones y anti patrones que
recurrentemente aparecen en escenarios diferentes por las propias necesidades
de empresas u organismos con necesidades diversas.

## Qué es GitOps

El término GitOps, surge en el año 2017 como __buzzy word__ gracias a
[WaveWorks](https://www.weave.works/). En su blog, existe un post muy claro
acerca de la [historia de
GitOps](https://www.weave.works/blog/the-history-of-gitops).

Lo que podemos afirmar acerca de GitOps es:

* Se utiliza Git como fuente de verdad principal de lo que se aplica en la
  infraestructura.
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

Estas aplicaciones, en el mejor de los casos se desarrollarán tratando de
aplicar los [12 factores](https://12factor.net/). Pero las aplicaciones
modernas, ya no constan de un único despliegue, sino de múltiples: uno para cada
aplicación. Por ejemplo, hoy día es muy común tener aplicaciones frontend de tipo
[SPA](https://en.wikipedia.org/wiki/Single-page_application) que consumen un 
backend, posiblemente desarrollado por el mismo equipo u otro equipo de
desarrolladores dentro del orgnismo.

Entonces cuando hagamos referencia a un despliegue con GitOps, probablemente
estemos desplegando una, dos o varias aplicaciones más (como es el caso de los
microservicios).

## ¿Cómo implementar el marco de trabajo?

Las posibilidades de implementar GitOps en kubernetes son varias. Sin embargo,
hay productos que se han afianzado más que otros, y este hecho puede ser
fácilmente visible al observar [los proyectos graduados de la
CNCF](https://landscape.cncf.io/card-mode?project=graduated). Si bien con el
pasar del tiempo, podremos extender el presente documento a nuevas herramientas,
actualmente comenzaremos por acotar el mismo a las siguientes:

* **[ArgoCD](https://argo-cd.readthedocs.io/en/stable/):** utilizaremos
  aplicaciones, proyectos y applicationsets para el despliegue continuo las
  aplicaicones.
* **[Helm charts](https://helm.sh/):** como empaquetador templatizado de cada
  aplicación.
* **[Helm Secrets](https://github.com/jkroepke/helm-secrets):** un plugin de
  helm que nos permitirá cifrar valores sensibles usando [sops](https://github.com/mozilla/sops).

La idea del marco, es la de extender estas herramientas a otros (anti) patrones
que se detecten y documentar qué solución orfecemos a cada caso.

## ¿Qué ofrece el marco de trabajo con GitOps?

* Describe (anti) patrones con cada herramienta utilizada.
* Desarrollado considerando escenarios muy diferentes y aplicado en clientes con
  estructuras distintas.
* Identifica y describe cómo implementar distintas etapas del proceso de
  despliegue de aplicaciones:
    * Armado de ambientes de forma declarativa.
    * Creación de un proyecto en ArgoCD acotando los permisos usando
    [RBAC](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/).
    * Despliegue de un conjunto de requerimientos usando GitOps.
    * Despliegue de aplicaciones usando GitOps.
* Soporte de Multicluster.

# Consideraciones

Para poder aplicar el marco de trabajo, es importante que las
aplicaciones a ser desplegadas cumplan la mayoría de los siguientes puntos:

* Apliquen en gran parte los [12 factores](https://12factor.net/).
* El código de cada aplicación debe versionarse en un repositorio Git, y junto al
  código debe proveerse un Helm Chart considerando los [patrones para el
  desarrollo de Helm Charts](../../patterns/helm/).
* Utilizar CI/CD que automaticen la publicación de:
    * Imágenes de contenedores en una registry OCI
    * Helm Chart en un repositorio de Charts o una registry OCI, considerando
      los problemas que conlleva el [uso de registries](/patterns/argocd/versionado-valores/#problemas-de-argocd-usando-helm-charts-en-registries-oci).
de charts o una registry OCI (puede ser cualquiera de los mencionados en el
punto anterior).
* Definir access tokens, service accounts o robot accounts para el acceso desde:
    * ArgoCD a repositorios Git.
    * ArgoCD a repositorios o registries OCI de Helm Charts.
    * El namespace de un cluster kubernetes a registries de contenedores para
      ser usadas como imagePullSecrets.
* Adoptar una estrategia de cifrado de datos asimétrico.

## Etapas del marco de trabajo

El marco de trabajo propone al menos dos instancias bien diferenciadas de
trabajo:

* **Configuración del ambiente:** esta etapa es la génesis de un ambiente.
  Durante su ejecución se creará un proyecto en Argo CD acotando quiénes podrán
  interactuar, un namespace en alguno de los clusters de kubernetes disponibles
  y se aplicarán políticas sobre el ambiente. Además, permite enlazar
  ordenadamente las aplicaciones ArgoCD que representan los despliegues de
  backing services, como la aplicación propiamente dicha, pero sólo el enlace,
  porque la gestión de ellas, es responsabilidad de otros roles y otra etapa.
* **Despliegue de aplicaciones:** la configuración anterior provee un _enganche_,
  un pasaje de postas, con esta etapa. Sin embargo, ofrece independencia entre
  las dos etapas en cuanto a su gestión (quién modifica los backing services,
  quién la aplicación, quién define las políticas del ambiente). Al ser
  **_opcional_** este enganche, si se utilizan se sigue un **flujo puro de
  GitOps**, mientras que si no se hace, permite el **uso de la UI de Argo CD**,
  respetando en ambos casos, los permisos asignados en la etapa previa. La
  modalidad de trabajo basada en la UI la consideramos un [anti patrón](/patterns/argocd/ui).
  Sin embargo, disponer de esta funcionalidad puede ser de gran utilidad para
  realizar pruebas preliminares al enlace entre etapas.

## Qué permisos considerar

Cada etapa antes mencionada será gestionada por personal con diferentes roles,
permitiendo así concretar determinadas tareas. Como estamos describiendo
un proceso íntegramente basado en Git, los permisos serán los que el repositorio
imponga a los usuarios del mismo. Por lo cual, si se utilizan plataformas como
Gitlab,  Github, Bitbucket, Azure Devops, entre varias otras, podemos hacer uso
de ramas protegidas y promover el uso de Merge o Pull Requests.

Si bien cada etapa utiliza repositorios Git respaldados de permisos como los
mencionados en el párrafo anterior, ArgoCD agrega más roles que deben
considerarse. ArgoCD provee un controlador de Kubernetes que llevará adelante
los despliegues que cada repositorio Git describa. Pero además de ello, ofrece
una interfaz gráfica desde donde es posible:

* Eliminar recursos de kubernetes
* Conectar con la consola de un contenedor en un Pod
* Ver los logs de cada contenedor de cada Pod

Entonces, definir roles de Argo CD es fundamental si es que se proveerá acceso a
la interfaz gráfica de Argo CD a varios usuarios.

En resumen, destacamos que es importante:

* Determinar los permisos de cada repositorio Git involucrado.
* Configurar ArgoCD para autenticar y recuperar la membresía a grupos de
  usuarios a través de algún Identity Provider:

!!! info
    Es importante destacar que en ningún momento se menciona el acceso
    directamente al cluster kubernetes. Nuestra propuesta considera las
    intervenciones durante los despliegues únicamente a través de ArgoCD.

# Problemas asociados al uso de ArgoCD

## Uso de la UI de ArgoCD

ArgoCD es una herramienta muy poderosa que nos permite implementar despliegue
continuo fácilmente. Sin embargo, al proveer de una interfaz gráfica, es muy
tentador la interacción mediante dicha interfaz. He aquí el primer antipatrón:
usar la UI es parecido a usar [kubectl de forma
imperativa](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/),
lo cuál nos priva de tener __**manifiestos declarativos que puedan
versionarse**__. Por ello, el **primer antipatrón** es el uso de la UI porque no
estamos aplicando GitOps.

!!! info
    En caso de recuperación ante desastres, el uso de la UI para cada despliegue
    requiere el uso de backups de los manifiestos que representan las
    aplicaciones de ArgoCD, o el uso de alguna herramienta que permita desplegar
    las aplicaciones desde manifiestos versionados. Sucede que en un punto,
    aparece el problema del huevo y la gallina, porque esto que mencionamos es
    justamente el rol que queremos darle a ArgoCD.

    El propio chart de ArgoCD, permite a partir de al versión 5.0.0, [instanciar
    una serie de aplicaciones directamente en su instación](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#500). 

## Acceso restringido de usuarios

Al instalar ArgoCD muchas veces con el afán de comenzar a interactuar con la UI,
no configuramos la autenticación de ArgoCD con un Identity Provider.

!!! info
    Es muy común utilizar diferentes proveedores de OIDC como es el caso de
    [dex](https://dexidp.io/) o [keycloak](https://www.keycloak.org/).

Al no tener un proveedor de identidad, en general utilizamos ArgoCD como
administradores. **Usar el usuario admin es un antipatrón** muy parecido al de
utilizar la cuenta root en un sistema Linux.

Al integrar [ArgoCD con un proveedor de
identidad](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#sso),
si podemos hacerlo directamente con la plataforma de versionado de código
utilizada por los desarrolladores (e incluso para alojar los repositorios de
GitOps), los mapeos de roles se simplificarán.

!!! info
    [GitLab](https://gitlab.com/) posee una excelente [integración con
    dex](https://dexidp.io/docs/connectors/gitlab/). Lo mismo sucede con
    [GitHub](https://dexidp.io/docs/connectors/github/). En estos casos, si
    podremos reusar los permisos de acceso al repositorio de una aplicación para
    definir cómo interactuar con ArgoCD, sin tener que replicar configuraciones
    de acceso en la plataforma de versionado y en ArgoCD.

Una vez definida la integración de ArgoCD con un proveedor de identidad, se
deben [mapear los roles a permisos](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/),
considerando al menos roles específicos para:

* **Administrador:** es un super administrador como el configurado por defecto
  cuando se instala ArgoCD sin la integración con OIDC. Si bien usar el
super administrador no es una buena práctica, es necesario disponer de tal rol.
* Para cada despliegue en un ambiente determinado, se deben considerar los roles
  de:
    * **Administrador de un ambiente:** proponemos este rol con
      capacidades para gestionar recursos del ambiente o crear manualmente
      aplicaciones desde la UI en determinados namespaces. Además, acceder
      a los contenedores y ver sus logs.
    * **Usuarios de sólo lectura de un ambiente:** proponemos este rol con
      capacidades limitadas para sólamente ver los recursos y logs de los
      contenedores. 


### ¿Es necesario el acceso al apiserver?

De todo lo antes descripto, aparece un nuevo eje que en algunos casos es 
una incógnita que se nos presenta a quienes gestionamos clusters de kubernetes,
y por consecuencia el acceso de usuarios al mismo. Cuando se observan las
capacidades que ofrece ArgoCD a los usuarios desde la UI, puede evidenciarse que
en la mayoría de los casos es suficiente el uso de ArgoCD y no acceso directo al
apiserver de kubernetes, evitando así las definiciones RBAC para cada cluster
kubernetes.

ArgoCD nos ofrece un acceso centralizado, con un idioma gráfico que simplifica
la interacción y visualización a usuarios no experimentados con kubernetes. Por 
ejemplo, desde ArgoCD podemos:

* Ver el estado de sincronización de una aplicación y sus manifiestos
* Ver los manifiestos en vivo que están corriendo en el cluster, como las
  diferencias que se aplicarían.
* Ver los logs de cada contenedor en un POD
* Acceder a la consola de un contenedor de un POD

!!! info
    Los logs pueden además navegarse desde kibana o grafana si se utiliza alguna
    estrategia de centralización de logs.

Además, ArgoCD permite limitar la visibilidad y accesos de cada usuario a través
de los proyectos de ArgoCD y [RBAC propias de
Argo](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/).

Para casos más complejos como realizar el debug de un contenedor, ArgoCD no
es suficiente. Por ello, no es que proponemos evitar la integración del
apiserver con OIDC. Simplemente ponemos sobre la mesa que en la mayoría de
los casos, ofrecer acceso únicamente a ArgoCD es suficiente para
roles que realizan desarrollo, o despliegue de aplicaciones con un uso
básico de kubernetes.

## ¿Cómo versionar los valores de una aplicación en diferentes ambientes?

La gran incógnita que surge con el uso de ArgoCD, es sobre cómo
pueden manejarse los valores de cada ambiente de forma independiente. La idea
es mantener los manifiestos similares para los diferentes ambientes, salvo por
las configuraciones particularidades de cada uno de ellos. Claro está que
deseamos aplicar el [décimo punto de los 12 factores](https://12factor.net/dev-prod-parity),
de igualdad entre desarrollo y producción. Por ello, la elección de la
herramienta de despliegue (helm charts o kustomize), debe permitirnos reutilizar
código de base y especificar las particularidades de cada ambiente.

[Helm](https://helm.sh) por su parte, se describe como un manejador de paquetes, pero en esencia
funciona como un lenguaje de templating reemplazando valores parametrizables.
Por su parte, [kustomize](https://kustomize.io/), se define como un manejador de
configuraciones libre de templates, donde las configuraciones se aplican a
través de agregados, modificaciones o eliminaciones. En este apartado,
expondremos las posibilidades de integración con ArgoCD, a fin de sentar
precedente del problema a solucionar y qué posibilidades tenemos.

### ArgoCD y Helm

La integración de ArgoCD con Helm es trivial. La complejidad aparece cuando se
necesita usar un chart con values propios de un ambiente. Un chart provee un
conjunto de values por defecto, pero _no sería correcto tener un values para cada
ambiente como parte del chart en sí_.

Un chart empaqueta una o varias componentes que hacen funcional una aplicación.
Por ello, el chart nos simplifica el despliegue de estas componentes, en un
ambiente. Analizando el concepto de ambiente y despliegue en relación al chart,
debemos aclarar que un despliegue de un chart no solamente representa un
ambiente, sino que además puede representar múltiples tenants. Por ejemplo, el
chart de wordpress puede representar el sitio de la empresa ACME, y tener tres
ambientes: producción, QA y testing. Además, ese mismo chart puede usarse para
desplegar el sitio de la empresa EJEMPLO, y tener dos ambientes: producción y
testing.

El propósito de un chart es el de reutilizar código a través de la
inyección de valores que hidratarán los manifiestos que darán identidad a un
tenant y un ambiente en particular. Por lo tanto, se sugiere desarrollar los
charts cumpliendo con las siguientes características:

* Los fuentes del chart es deseable que se **alojen junto con los fuentes de
  la aplicación**. Al igual que la imagen OCI generada a partir de los fuentes del
  repositorio, los charts deben seguir un flujo similar que evolucione con las
  versiones de producto.
* Se recomienda que los charts sigan un esquema de **versionado semántico
  independiente del versionado de producto**.
* Es deseable disponibilizar los charts en un repositorio de charts o una
  registry OCI. Sea público o privado, el artefacto luego será consumido
  utilizando una **referencia al nombre y una versión específica del chart**.

Ahora bien, tenemos entonces un chart en un repositorio de charts, con un
conjunto de valores por defecto. La incógnita aquí, es como integrar este chart
en ArgoCD sin caer en el ya enunciado [antipatrón de usar la UI](#uso-de-la-ui-de-argocd).
Analizamos entonces qué opciones nos brinda ArgoCD para crear aplicaciones
basadas en Helm con valores para cada ambiente:

* Mantener en el mismo repositorio de los fuentes del chart, el valor para cada
  ambiente. Esto nos llevaría a crear una aplicación en ArgoCD de tipo Helm, que
  apunte a un repositorio Git y un directorio donde están los fuentes del chart.
  Pero como mencionamos en párrafos anteriores, esto sería un **antipatrón** por
  las siguientes razones:

    * No estamos utilizando el artefacto creado con el chart empaquetado en una
      versión determinada.
    * Puede que un chart tenga más usos que los ambientes de despliegue (como en
      el ejemplo de wordpress).
    * Incluso si fuera una aplicación que no cae en el problema de múltiples
      tenants, los valores de diferentes ambientes serían modificables por el
      mismo conjunto de usuarios. Esto más que un antipatrón es un **problema de
      seguridad** que varios organismos no se permiten dar.

* ArgoCD respeta las opciones que helm admite para interpolar valores. Así es
  como [`helm install`](https://helm.sh/docs/helm/helm_install/) admite usar una
  **URL como  value**. Entonces podemos utilizar helm de la siguiente forma:

    ```sh
    helm template demo-app-mikroways/demo-app -f https://bit.ly/3CCoAQy
    ```

    Luego, podemos replicar esta misma idea en una aplicación de argo con el
    siguiente manifiesto:

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: demo-app
    spec:
      destination:
        namespace: default
        server: https://kubernetes.default.svc
      project: default
      source:
        chart: demo-app
        repoURL: https://mikroways.github.io/demo-app/
        targetRevision: 0.1.*
        helm:
          valueFiles:
          - https://bit.ly/3CCoAQy
    ```
    
    Esta opción no sería una mala solución porque nos permite mantener los
    charts por un lado y los values en una URL independiente para cada ambiente.
    Sin embargo, los values deben quedar accesibles desde argocd. Esto presenta
    un gran problema de seguridad cuando se deben disponibilizar datos
    sensibles. Por otro lado, los valores no quedarán versionados, tampoco
    respetando la filosofía GitOps. Por esto consideramos esta práctica como un
    **antipatrón**.

* Un repositorio por cada ambiente. La idea de esta solución es la de crear un
  repositorio para cada ambiente con un chart extremadamente simple. Será u
  chart sin templates, que únicamente se define como [dependencia](https://helm.sh/docs/helm/helm_dependency/)
  del chart original. Incluso, con esta propuesta es posible combinar en un
  único chart diversos charts que se agrupan para simplificar el despliegue.
  Siguiendo esta idea, el chart del cuál dependemos debe estar en un **repositorio
  de charts** o una registry **OCI**. Para crear un chart de tipo dependencia,
  podemos seguir los siguientes pasos:

    ```bash
    helm create demo-app-production
    cd demo-app-production
    rm -fr templates
    ```

    Luego, restan modificar unos archivos:

      * Editar `Chart.yml` agregando el siguiente extracto de código:

        ```yaml
        # Edit above lines as you like...
        dependencies:
          - name: demo-app
            version: 0.1.*
            repository: https://mikroways.github.io/demo-app
        ```

      * Luego editar el values, agregando los valores necesarios para este
        ambiente en `values.yaml`

        ```yaml
        demo-app:
          message: "Hello from production environment"
        ```

      * A veces conviene explotar los values en varios archivos, donde cada uno
        se dedica a configurar una parte determinada de la aplicación,
        o separarlo porque los valores sensibles se encriptarán para no
        exponerse en git.

    Como paso final, verificamos todo funciona de forma esperada:

    ```bash
    helm dependency update
    helm template .
    ```

!!! warning
    El uso de charts en una registry OCI puede traer problemas. El problema
    radica en que el login a una registry OCI se realiza con la URL sin
    considerar el path de la URL. Cuando tenemos diferentes repositorios OCI 
    de tipo helm en ArgoCD que comparten el mismo hostname, puede suceder que
    ArgoCD falle de forma inesperada. El problema se da cuando se dispone de un
    un repositorio OCI con la URL oci://registry.example.net/mikroways/project-a/charts
    y otro con la URL oci://registry.example.net/mikroways/project-b/charts. Cada
    registry utilizará además, usuarios diferentes para su acceso. Entonces, si
    ArgoCD configura dos repositorios helm de tipo OCI, cada uno con diferentes
    usuarios y contraseña, a veces algun repositorio no podrá converger por no
    poder hacer el login. Lo mismo sucede con docker login: no es posible tener
    dos usuarios diferentes para un mismo hostname de registry.



## El patrón app of apps.


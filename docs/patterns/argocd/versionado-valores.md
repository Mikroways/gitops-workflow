# Versionado de valores


## ¿Cómo versionar los valores de una aplicación en diferentes ambientes?

La gran incógnita que surge con el uso de ArgoCD, es sobre cómo
se pueden manejar los valores de cada ambiente de forma independiente. La idea
es mantener los manifiestos similares para los diferentes ambientes, salvo por
las configuraciones específicas de cada uno de ellos. Claro está que
deseamos aplicar el [décimo punto de los 12 factores](https://12factor.net/dev-prod-parity),
de igualdad entre ambientes. Para esto, la elección de la herramienta de
despliegue debe permitirnos reutilizar código de base y especificar las
diferencias en cada ambiente. 

En términos de facilitar el despliege de componentes, existen herramientas que
nos permiten simplificar y automatizar este proceso, como Helm y Kustomize.
Por su parte [Helm](https://helm.sh) se describe como un manejador de paquetes,
pero funciona como un lenguaje de templating, reemplazando valores parametrizables.
Por otro lado, existe [kustomize](https://kustomize.io/), que se define como un manejador de
configuraciones libre de templates, donde las mismas se aplican a través del
agregado, modificación o eliminación de código. 
En este apartado analizamos las posibilidades de la integración de Helm con
ArgoCD como paso integral en el flujo de Gitops.

## ArgoCD y Helm

La integración de ArgoCD con Helm es trivial. La complejidad aparece cuando se
necesita usar un chart con _valores propios para un ambiente_. Un chart provee un
conjunto de valores por defecto, pero _**no sería correcto** tener valores para
cada ambiente como parte del chart_.

Un chart empaqueta una o varias componentes que hacen funcional una aplicación.
Por ello, los charts simplifican el despliegue de componentes en un ambiente.
Analizando el concepto de ambiente y despliegue en relación al chart,
debemos aclarar que un despliegue de un chart no solamente representa un
ambiente, sino que además puede representar diferentes tenants o dueños. Por ejemplo, el
chart de wordpress puede representar el sitio de la empresa Acme, y tener tres
ambientes: producción, QA y testing. Además, ese mismo chart puede usarse para
desplegar el sitio de la empresa Ejemplo, y tener dos ambientes: producción y
testing. Y así, ad infinitum.

En definitiva, el propósito de un chart es el de reutilizar código a través de la
inyección de valores, hidratando manifiestos con valores que dan identidad a un
tenant y ambiente en particular. Por lo tanto, el chart debe ser lo
más genérico y parametrizable posible. Para ello, recomendamos seguir las
[buenas prácticas](https://helm.sh/docs/chart_best_practices/) sugeridas por
Helm. Nosotros realizamos los siguientes puntos, en favor del flujo de GitOps:

* Los fuentes del chart es deseable que se **alojen junto con los fuentes de la
  aplicación**. Al igual que la OCI (imagen de contenedor), que es generada a partir
  de fuentes en un repositorio, los charts de la aplicación deben seguir un flujo
  similar que evolucione con las versiones de producto.
* Se recomienda que los charts sigan un esquema de **versionado semántico
  independiente del versionado de producto**. Helm documenta muy bien cómo
  [versionar semánticamente](https://helm.sh/docs/topics/charts/#charts-and-versioning).
* Es deseable disponibilizar los charts en un repositorio de charts o una
  registry OCI. Sea este público o privado, el artefacto luego será consumido
  utilizando una **referencia al nombre y versión del chart**.

Ahora bien, tenemos entonces un chart en un registry, con un conjunto de valores
definidos por defecto. La incógnita aquí, es como trabajar con este chart e
integrarlo con ArgoCD sin caer en el ya enunciado [antipatrón de usar la
UI](ui.md).

Analizamos entonces qué opciones nos brinda ArgoCD para crear aplicaciones
basadas en Helm, con valores diferenciados para cada ambiente:

### Valores por ambiente en los fuentes del chart

Esta estrategia propone mantener en el mismo repositorio de los fuentes del
chart el valor para cada ambiente. Esto nos lleva a crear una aplicación
ArgoCD de tipo Helm, que apunte a un repositorio Git y un directorio donde están
los fuentes del chart. Considerando que el mismo repositorio alberga en una
carpeta determinada valores específicos para cada ambiente, podremos utilizar el
campo [`spec.source.helm.valueFiles`](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values-files)
de las aplicaciones ArgoCD. Un ejemplo de una aplicación de este tipo sería:

```yaml linenums="1"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-custom-app
  namespace: argocd
spec:
  project: default
  source:
    path: charts/my-custom-app
    repoURL: https://my-private-repo/my-custom-app.git
    targetRevision: HEAD
    helm:
      valueFiles:
        - env-values/testing.yaml
  destination:
    server: "https://kubernetes.default.svc"
    namespace: kubeseal
```

Ahora analizaremos algunos aspectos de este escenario:

* No estamos utilizando el artefacto desde un repositorio de charts, sino
  directamente desde git (10).
    * El chart se encuentra en la rama HEAD (11), dentro de la carpeta
      `charts/my-custom-app` (9).
    * El valor para este ambiente se toma de `env-values/testing.yaml` relativo al
      chart (14).
* Puede que un chart tenga muchos más usos que los ambientes de despliegue
  (como en el ejemplo de wordpress).
* Desde la perspectiva de seguridad, los valores de diferentes ambientes residen
  en un mismo repositorio, siendo entonces visibles y modificables por el mismo
  conjunto de usuarios.

Por lo antes expuesto, consideramos esta estrategia como un **antipatrón**.

### Valores por URL

ArgoCD respeta las opciones que helm admite al usarlo desde la interfaz de línea
de comandos. Así es como [`helm install`](https://helm.sh/docs/helm/helm_install/)
perrmite usar una **URL como  valor**, siendo la URL un link a un archivo de
valores para hidratar el chart. Entonces podemos utilizar helm de la
siguiente forma:

```sh
helm template demo-app-mikroways/demo-app -f https://bit.ly/3CCoAQy
```

Luego, podemos replicar esta misma idea en una aplicación de argo con el
siguiente manifiesto:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
1Gmetadata:
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

### Un repositorio por ambiente


Aquí la idea radica en crear un repositorio para cada ambiente, de forma que
**los valores de cada ambiente se versionen de forma independiente.**
Esto facilita la gestión y el mantenimiento de las diferentes versiones de los
valores utilizados en cada ambiente, permitiendo realizar cambios específicos en
cada uno de ellos de manera independiente.

!!! info
    A partir de la versión 2.6 de ArgoCD es posible utilizar [múltiples
    repositorios git](https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/#helm-value-files-from-external-git-repository)
    para los valores, separnado entonces el chart, de los valores usados para
    desplegarlo.

#### Versión de ArgoCD 2.6 o superior

En este escenario, las aplicaciones ArgoCD ya implementan en su esencia una
estrategia mas pura respecto de GitOps, dado que podemos fijar una versión de
chart y utilizar diferentes repositorios git para hidratar sus manifiestos.
De esta manera, se puede tener un repositorio para el chart de Helm y un
repositorio separado para los valores de configuración de ambientes. 
Esto permite una mayor flexibilidad y un mejor control de versiones.
El siguiente ejemplo, muestra una aplicación de estas características:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  sources:
  - repoURL: 'https://prometheus-community.github.io/helm-charts'
    chart: prometheus
    targetRevision: 15.7.1
    helm:
      valueFiles:
      - $values/charts/prometheus/values.yaml
  - repoURL: 'https://git.example.gom/org/value-files.git'
    targetRevision: dev
    ref: values
```
Notar en el manifiesto, la `repoURL` con el archivo de valores versionado, y un
`targetRevision` que hace referencia al ambiente 'dev'. El targetRevision puede
referenciar una tag, una rama o un commit de Git.

Esta práctica es una excelente práctica y por ello, la consideramos un **patrón de gitops**.

#### Versiones de ArgoCD previas a la 2.6

!!! warning
    Si bien la estrategia aquí descripta funciona para versiones anteriores a
    2.6, la práctica puede ser conveniente incluso en esta versión de ArgoCD.

En este caso, proponemos crear un repositorio git correspondiente al despliegue
de un ambiente. Para ello, este respositorio debe albergar no sólo los valores
como en el caso anterior, sino que además, será un chart con las siguientes
características:

* Sin templates, o alguno muy simple.
* Definirá [dependencias](https://helm.sh/docs/helm/helm_dependency/) a uno o
  varios charts. Las dependencias serán de los charts que sí representan una
  aplicación.

Para esto, los charts de los que dependemos **deben estar almacenados en
repositorio de charts o registries OCI**.

Los pasos para crear un chart de estas características son muy simples:

```bash
helm create demo-app-production
cd demo-app-production
rm -fr templates
```

Luego, resta modificar los siguientes archivos:

* Agregar en `Chart.yml` las dependencias:

    ```yaml
    # Edit above lines as you like...
    dependencies:
      - name: demo-app
        version: 0.1.*
        repository: https://mikroways.github.io/demo-app
    ```
    > Notar que usamos como versión 0.1.*, aliviando el patch number del Chart
    > del que dependemos.

* Editar los valores del despliegue correspondiente al ambiente en `values.yaml`

    ```yaml
    demo-app:
      message: "Hello from production environment"
    ```
  > Observar que los valores se deben poner bajo el nombre de la dependencia, en
  > este caso **demo-app**. Pueden usarse **alias en las dependencias**.

* A veces conviene explotar los valores en varios archivos, donde cada uno
  se dedica a configurar una parte determinada de la aplicación,
  o separarlo porque los valores sensibles serán **cifrados** para no
  exponerse en git.
* Agregar un `.gitignore` para no versionar los siguientes archivos:

    ```
    Chart.lock
    charts/
    ```
    > De esta forma podemos librar a ArgoCD de no seguir el lock versionado y
    > que las dependencias se descarguen cuando surje un nuevo chart respecto
    > del wildcard usado.
Como paso final, verificamos el funcionamiento del nuevo chart:

```bash
helm dependency update
helm template .
```

### Problemas de ArgoCD usando Helm charts en registries OCI

Si bien Helm soporta descargar los charts desde repositorios de charts o
registries OCI, en el último caso existen problemas que no queremos dejar de
mencionar. No son problemas de ArgoCD ni Helm, solamente es entender cómo es que
funcionan las registries OCI. El login a una registry OCI se hace a un host,
al host de la registry, y nada importa la URL completa. Por ejemplo, si tenemos
las siguientes URLS:

1. https://registry.example.net/mikroways/project-a/charts
1. https://registry.example.net/mikroways/project-b/charts

Debemos ser consientes que si se hace el login a la URL 1 o la 2, en realidad
estamos realizando el login a https://registry.example.net. Algunas registries,
por ejemplo la de Gitlab, permiten definir diferentes tokens de acceso para las
diferentes URLs 1 y 2. Luego si usamos el token de 1 en 2, tendremos un error.
Lo mismo al revés.


ArgoCD gestiona entonces el acceso a repositorios o registries por medio de
credenciales. Las credenciales para una registry OCI se dará de alta al igual
que los reposiorios convenvionales, pero ArgoCD hará el login a cada credencial
que represente una registry OCI. Si se dieran de alta las 2 URLs del ejemplo,
entonces solamente el último login quedará válido, y algun comando helm fallará
cuando trate de acceder al chart disponible en la otra URL.

!!! info
    Podemos gestionar un token que tenga acceso a cualquier URL de una registry
    y con esto solucionaremos el problema. El tema es que la granularidad de
    permisos se ve comprometida y en caso de que sea un problema, es
    recomendable utilizar repositorios para charts en vez de registries OCI.

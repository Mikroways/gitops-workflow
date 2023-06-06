# Repositorios Git

El marco de trabajo entonces requiere la definición de diferentes repositorios,
que como se menciona en la sección previa, permiten diferenciar dos etapas
claras:

1. Creación y configuración del ambiente.
1. Despliegue en un ambiente existente.

Claramente el punto 1 es previo al 2, y para llevarlo adelante proponemos el uso
de [**ArgoCD Applicationsets**](https://argocd-applicationset.readthedocs.io/en/stable/).
Como puede verse en su documentación, los Applicationsets permiten [diferentes
estrategias](https://argocd-applicationset.readthedocs.io/en/stable/Generators/)
a la hora de generar ArgoCD Applications. La elección de cuál generator utilizar
depende de cada organización, necesidad o requerimiento. Nosotros proponemos un
[ejemplo basado en Git](https://github.com/Mikroways/argo-gitops-demo-example/)
cuyo manifiesto sería algo así:

```yaml
applicationsets:
  - name: equipos-por-producto
    generators:
      - git:
          repoURL: GH_REPO_URL
          revision: GH_REVISION
          files:
              - path: projects/**/values.yaml
    template:
      metadata:
        name: '{{path[1]}}-{{path[2]}}-{{path[3]}}-{{path[4]}}'
      spec:
        syncPolicy:
          automated:
            prune: false
            selfHeal: true
        project: default
        source:
          path: charts/custom-argo-project
          repoURL: GH_REPO_URL
          targetRevision: GH_REVISION
          helm:
            values: |
              argo-project:
                namespace: '{{path[1]}}-{{path[2]}}-{{path[4]}}'
                cluster:
                  name: '{{ path[3] }}'
                  nameSuffix: 'cluster'
                argo:
                  namespace: argocd
                  baseApplication:
                    helm:
                      parameters:
                        - name: namespace
                          value: '{{path[1]}}-{{path[2]}}-{{path[4]}}'
                    syncPolicy:
                      automated: {}
            valueFiles:
              - secrets+age-import-kubernetes://argocd/helm-secrets-age-private-key#key.txt?{{path}}/values.yaml
        destination:
          server: https://kubernetes.default.svc
          namespace: default
```

> Este fuente puede verse en [este enlace](https://github.com/Mikroways/argo-gitops-demo-example/blob/main/kind/helmfile.d/values/argocd-apps/values.yaml.tpl)

Donde `GH_REPO_URL` y `GH_REVISION` deben reemplazarse con los valores
adecuados. En este ejemplo, podemos ver que el generador basado en Git barrerá
recursivamente el directorio `projects/**/values.yaml` buscando
aquellos archivos llamados `values.yaml`. Para cada valor, creará una aplicación
como muestra el `template`.

!!! info
    El ejemplo aquí expuesto es parte de un ejemplo completo, funcional que hemos
    dispuesto como GitHub Template para que cualquier usuario pueda verificar el
    funcionamiento de nuestro marco de trabajo.

Si se observa la aplicación ArgoCD que se crea, es una aplicación de tipo Helm
que usará un Chart cuyos fuentes están en la carpeta
[`charts/custom-argo-project`](https://github.com/Mikroways/argo-gitops-demo-example/tree/main/charts/custom-argo-project)
del ejemplo entregado. No es más que un Helm Charts wrapper, que depende de otro
chart desarrollado por nosotros, [**argo-project**](https://github.com/Mikroways/argo-gitops-flow/tree/main/charts/argo-project).
Será este chart argo-project, el responsable de enlazar, ordenar y desplegar el
ambiente, luego los requerimientos y por último nuestra aplicación definitiva.
Para ello, se utiliza el patrón propuesto por ArgoCD, [app of apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern).

Luego, cada aplicación creada por medio del chart mencionado en el párrafo
anterior, se encargará de:

* Crear un proyecto de ArgoCD con roles para administrar el namespace y
  accederlo en forma de sólo lectura.
* Crear una aplicación ArgoCD base para el proyecto en cuestión. Esto se realiza
  con otro chart provisto por Mikroways llamado [**argo-base-app**](https://github.com/Mikroways/argo-gitops-flow/tree/main/charts/argo-base-app).
  Será el encargado de otras tareas:
  * Crear el namespace en un cluster determinado.
  * Crear opcionalmente uno o más secretos para ser usados como
      imagePullSecrets.
  * Aplicar políticas del namespace opcionales y NetworkPolicy.
* Crear una aplicación ArgoCD que despliegue los requerimientos de backing
  services.
* Crear una aplicación ArgoCD que despliegue la aplicación propiamente dicha.

Los últimos dos puntos anteriores, se corresponden con el inciso 2 que
mencionamos al comienzo de esta sección: **despliegue en un ambiente
existente**. Los repositorios de 2, pueden ser un mismo repositorio con dos
directorios diferentes: uno para los requerimientos y otro para la aplicación en
sí, o dos repositorios independientes. Esto ofrece tanta granularidad como se
quiera.

## Relación entre permisos en Git y ArgoCD

Si el proveedor de identidad usado para configurar ArgoCD se corresponde con la
plataforma de Git, tenemos un escenario mucho más simple de gestionar que cuando
tal integración no es viable. La afirmación anterior, se debe a que cuando
ArgoCD utiliza los roles que surgen desde la misma plataforma de Git, entonces
los permisos de quienes acceden a determinados repositorios puede ser los mismos
que se usan en los Argo Projects. Si no existe una integración del estilo, por
ejemplo cuando se utilizan roles en Active Directory o LDAP, luego los permisos
asignados ne las plataformas de Git serán independientes de los permisos
asignados en ArgoCD.

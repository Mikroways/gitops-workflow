# La UI de ArgoCD

ArgoCD es una herramienta muy poderosa que nos permite implementar despliegue
continuo fácilmente. Sin embargo, al proveer de una interfaz gráfica es muy
tentador interacturar mediante dicha interfaz. He aquí el primer antipatrón:
usar la UI es similar a usar [kubectl de forma
imperativa](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/),
lo cuál nos priva de tener __**manifiestos declarativos que puedan
versionarse**__. Por ello, el **primer antipatrón** es el uso de la UI porque no
estamos aplicando GitOps.

Usando la UI para crear una aplicación de Argo CD parece ser lo más intuitivo, y
realmente es lo que las personas valoramos. Más que nada porque tenemos una
ventana visual, con un formulario que, a través de campos nos permite completar
y configurar nuestro despliegue. Nuestro despliegue sí usará gitops, pero la
creación de la aplicación en sí no queda en git. Si bien esta forma de proceder
es muy cómoda, el resultado de crear esta aplicación será un *manifiesto
kubernetes representado por el CRD Application*. Este manifiesto deberá entonces
manternerse desde la UI y realizar backups para garantizar su disponibilidad,
porque en definitiva, la UI desplegará una aplicación cuyo manifiesto no quedará
versionado y en consecuencia sin GitOps. 

!!! info
    Para el caso de tener que afrontar una recuperación ante desastres, habiendo
    utilizado la UI para los despliegues, debemos considerar backups para los
    manifiestos que representan las aplicaciones de ArgoCD. Idealmente,
    esperaríamos poder utilizar alguna herramienta que permita desplegar las
    aplicaciones desde manifiestos versionados. Y justamente es esto lo que hace
    ArgoCD con nuestras aplicaciones, pero no con sus propios manifiestos.

    El propio chart de ArgoCD, permitía instanciar una serie de aplicaciones
    usando `server.additionalApplications` pero a partir de la versión [5.0.0](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#500)
    removieron esta posibilidad y se creó un nuevo [chart para gestionar
    aplicaciones, proyectos e incluso applicationsets](https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps).


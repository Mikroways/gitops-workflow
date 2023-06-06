# La UI de ArgoCD

ArgoCD es una herramienta muy poderosa que nos permite implementar despliegue
continuo fácilmente. Sin embargo, al proveer de una interfaz gráfica es muy
tentador interacturar mediante dicha interfaz. He aquí el primer antipatrón:
**usar la UI.**

Este antipatrón es simil a usar [kubectl de forma
imperativa](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)
en que nos priva de tener _**manifiestos declarativos que puedan
versionarse**_. Cuando usamos la interfaz gráfica de ArgoCD, nos privamos de
versionar las configuraciones deseadas para crear nuestras aplicaciones mediante
manifiestos. Por ello, el **primer antipatrón** es el uso de la UI porque no
estamos aplicando GitOps.

Usando la UI para crear una aplicación de Argo CD parece ser lo más intuitivo, y
realmente es lo que las personas valoramos. Más que nada porque tenemos una
ventana visual con un formulario que, a través de campos, nos permite completar
y configurar nuestro despliegue.

Nuestro despliegue usará Gitops, pero la creación de la aplicación no lo
hará. Si bien esta forma de proceder parece cómoda a primera vista, el resultado
de crear esta aplicación vía la UI será un _manifiesto kubernetes representado
por el Custom Resource Definition (CRD) de ArgoCD llamado "Application"_. Este
manifiesto es importante porque define cómo se debe crear y configurar la
aplicación, pero si se crea mediante la UI, no se puede versionar en GitOps, lo
que puede causar problemas a largo plazo. Este manifiesto deberá entonces
manternerse desde la UI y deberemos realizar backups para poder garantizar su
disponibilidad. En definitiva, la UI desplegará una aplicación cuyo manifiesto
no quedará versionado, y en consecuencia fuera del marco de trabajo de GitOps.

!!! info
    Para el caso de tener que afrontar una recuperación ante desastres, habiendo
    utilizado la UI para los despliegues, debemos considerar backups para los
    manifiestos que representan las aplicaciones de ArgoCD. Idealmente,
    esperaríamos poder utilizar alguna herramienta que permita desplegar las
    aplicaciones desde manifiestos versionados. Y justamente es esto lo que hace
    ArgoCD con nuestras aplicaciones, pero no con sus propios manifiestos.

    El propio chart de ArgoCD permitía instanciar una serie de aplicaciones
    usando `server.additionalApplications` pero a partir de la versión [5.0.0](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#500)
    removieron esta posibilidad y se creó un nuevo [chart para gestionar
    aplicaciones, proyectos e incluso applicationsets](https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps).

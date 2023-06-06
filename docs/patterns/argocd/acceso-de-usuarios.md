# Acceso restringido

## Autenticación de usuarios

Al instalar ArgoCD pocas veces se configura su autenticación con un [Proveedor
de Indentidad](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#sso)
a través de [OpenID Connect (OIDC)](https://openid.net/connect/).

!!! info
    ArgoCD ofrece varias formas de integrar con proveedores de identidad, incluso
    usando productos que simplifican la autenticación con LDAP o Active Directory
    como es el caso de [dex](https://dexidp.io/) o [keycloak](https://www.keycloak.org/).

Al no tener un proveedor de identidad, en general utilizamos ArgoCD con el
usuario administrador. **Usar el usuario admin es un antipatrón**, similar
al de utilizar la cuenta root en un sistema Linux.

Al integrar ArgoCD con un proveedor de identidad, será posible [mapear grupos
del proveedor de identidad con roles de ArgoCD](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/).
Los roles agrupan permisos para desarrollar determinadas acciones, pudiendo así
aplicar RBAC (Role Based Access Control). Usar un proveedor de identidad en
ArgoCD tiene un gran beneficio cuando compartimos los grupos de usuarios con la
plataforma de versionado de código fuente. (ej gitlab, bitbucket). Al hacer
esto, podemos establecer roles de acceso correlacionados entre ambas
plataformas, lo que ahorra tiempo y trabajo al equipo de IT en la gestión de
accesos.

!!! info
    [GitLab](https://gitlab.com/) posee una excelente [integración con
    dex](https://dexidp.io/docs/connectors/gitlab/). Lo mismo sucede con
    [GitHub](https://dexidp.io/docs/connectors/github/). En ambos casos, es
    posible reusar permisos de acceso al repositorio (o grupo de repositorios)
    de una aplicación para definir cómo sus miembros pueden interactuar con
    ArgoCD, sin tener que replicar configuraciones de acceso tanto en la
    plataforma de versionado como en ArgoCD.

Una vez definida la integración de ArgoCD con un proveedor de identidad, se
deben mapear los grupos a roles, considerando al menos roles específicos para:

* **Administrador:** Es super administrador como el configurado por el instalador
  de ArgoCD, sólo que aquí en vez de ser un único usuario, la idea es que un
  grupo de usuarios tenga este perfil. Si bien usar un rol de super
  administrador no es una buena práctica, es necesario disponer del rol para
  determinadas acciones de gestión.
* Además, para cada despliegue de producto en un ambiente, **_proponemos_** los
  siguientes roles:
  * **Administrador de ambiente:** puede gestionar recursos del ambiente, y
      crear manualmente aplicaciones desde la UI en un namespace de kubernetes.
      Ademas el rol puede [acceder a los contenedores a través de la consola
      web](https://argo-cd.readthedocs.io/en/stable/operator-manual/web_based_terminal/)
      y ver sus logs.
  * **Usuarios de sólo lectura de un ambiente:** se limita a poder visualizar
      todos los recursos de un ambiente, además de los logs de los
      contenedores en el namespace.

La separación de roles nos permitirá tener un grupo de superadministradores, así
como también roles de administrador y de solo lectura para cada
ambiente de producto. Vale la pena analizar esta separación de
responsabilidades, en parte por que nos permite dar acceso a usuarios sin
experiencia en Kubernetes para que puedan observar cómo interactúan los objetos
además de analizar los logs de los contenedores.

## ¿Es necesario el acceso a kuberentes usando kubectl?

Todo lo mencionado en las secciones previas aplica únicamente a ArgoCD, y será
este producto el que termina en definitiva interactuando en nombre nuestro
con kubernetes.

Sin embargo, esto nada tiene que ver con el uso de kubernetes por parte de los
usuarios finales. También podemos limitar el acceso a kubernetes via kubectl.
El apiserver de kubernetes permite su integración con [proveedores de
identidad](https://github.com/dexidp/dex/issues/787), y podemos acotar los
accesos de cada grupo definido en el proveedor mediante RBACs.

Aquí se presenta la cuestión de si el acceso al apiserver de un cluster
kubernetes a través de kubectl es algo que vamos a ofrecer a los usuarios
finales o no. Esta decisión dependerá de factores específicos de cada
organización, lo cual puede depender de la capacitación disponible y el
conocimiento interno de la herramienta.

ArgoCD ofrece un acceso centralizado, con un idioma gráfico que simplifica
la interacción y visualización a usuarios no experimentados con kubernetes. Por
ejemplo, desde ArgoCD podemos:

* Ver el estado de sincronización de una aplicación y sus manifiestos
* Ver los manifiestos en vivo que están corriendo en el cluster, como las
  diferencias que se aplicarían.
* Ver los logs de cada contenedor en un POD
* Acceder a la consola de un contenedor de un POD

Además, ArgoCD permite limitar la visibilidad y accesos de cada usuario a través
de los proyectos de ArgoCD y [RBAC propias de Argo](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/).

Para casos más complejos como realizar el debug de un contenedor, ArgoCD no
es suficiente. Por ello, no proponemos evitar la integración del apiserver de
kubernetes con OIDC, sino que proponemos tener presente las diferentes
posibilidades de interacción con los clusters kubernetes.

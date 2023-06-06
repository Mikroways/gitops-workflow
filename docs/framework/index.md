# Objetivo

Basándonos en los [(anti) patrones](../patterns) mencionados en la sección anterior,
creamos esta propuesta de trabajo que hemos denominado **marco de trabajo con
GitOps** con el propósito de simplificar la adopción de buenas prácticas.

Al aplicar este marco, se permitirá el **despliegue continuo** de
aplicaciones en **ambientes creados utilizando GitOps**, teniendo en cuenta los
siguientes aspectos:

* Despliegues en clusters diferentes.
* Acotar los recursos asignados a cada ambiente mediante ResourceQuotas y
  LimitRange.
* Definición opcional de NetworkPolicies.
* Instrumentación de proyectos de ArgoCD con roles asociados a un proveedor de
  identidad para limitar las acciones permitidas.
* Configuración en ArgoCD de repositorios por proyecto, permitiendo el
  acceso a repositorios Git o Helm Charts privados.
* Disponibilizar secretos con imagePullSecret dentro del namespace para
  simplificar el despliegue de contenedores que utilicen registries
  privadas.
* Opción de desplegar los backing services (por ejemplo, bases de datos o
  servicios SMTP de email) antes al despliegue de la aplicación en sí.

Además, se proporcionará un ejemplo de cómo cifrar datos evitando así el
versionado en Git de datos sensibles.

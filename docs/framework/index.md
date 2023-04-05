# Objetivo

En base a los [(anti) patrones](../patterns) mencionados en la sección previa,
creamos esta propuesta de trabajo que hemos denominado **marco de trabajo con
GitOps** con el propósito de simplificar la adopción de buenas prácticas. El
resultado de aplicar este marco permitirá el **despliegue continuo** de
aplicaciones en **ambientes también creados utilizando GitOps**, considerando:

* Despliegues en clusters diferentes.
* Acotar los recursos asignados a cada ambiente utilizando ResourceQuotas y
  LimitRange.
* Definición opcional de NetworkPolicies.
* Instrumentación de proyectos de ArgoCD, con roles asociados a un proveedor de
  identidad con el propósito de limitar las acciones permitidas.
* Configuración en ArgoCD  de repositorios por proyecto de forma de permitir el
  acceso a repositorios Git o Helm Charts privados.
* Disponibilizar secretos con imagePullSecret dentro del namespace para 
  simplificar el despliegue de contenedores que utilicen registries
  privadas.
* Ofrecer la posibilidad de desplegar, previo al despliegue de la
  aplicación misma, aquellos backing services que sean requeridos.

Además, ejemplificar cómo cifrar los datos evitando así el versionado en Git de
datos sensibles.

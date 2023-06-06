# Introducción

Helm dispone de una excelente [documentación](https://helm.sh/docs/). Incluso
promueve la adopción de [buenas prácticas](https://helm.sh/docs/chart_best_practices/)
y sugiere algunos [trucos para el desarrollo de charts](https://helm.sh/docs/howto/charts_tips_and_tricks/).

Sin embargo, en este apartado trataremos temas que quedan librados a cada
implementación, y es por ello que los ponemos aquí sobre la mesa para establecer
cuál es el mejor enfoque que hemos encontrado para abordar determinadas
situaciones. Estas son:

* [Mantener un único chart por aplicación, o un chart que despliega varias
  aplicaciones](./chart-vs-charts.md). La pregunta apunta a si conviene
  desarrollar un chart que despliegue por ejemplo un backend y un frontend, o
  mejor tener un chart para el backend y otro para el frontend.
* [Analizar en qué momento conviene ejecutar migraciones de esquemas de bases de
    datos](./schema-migrations.md). La disyuntiva surge en si utilizar
  initContainers para aplicar parches a una base de datos es correcto, o mejor es
  emplear otra estrategia.
* [Cómo manejar los requerimientos de un chart](./requirements.md). Desplegar un
  chart puede requerir algunos objetos sean creados con antelación, por ejemplo
  el uso de secretos necesarios como imagePullSecret.

Hay un tema que es importante mencionar relacionado a la publicación de Helm
Charts en registries OCI. El problema se menciona en la sección donde proponemos
un [esquema de versionado de valores de un despliegue](/patterns/argocd/versionado-valores/#problemas-de-argocd-usando-helm-charts-en-registries-oci)

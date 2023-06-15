# Ejemplos que ayudan a comprender el flujo

Para poder comprender el funcionamiento del [flujo](../framework/index.md),
hemos dispuesto un [repositorio template en
GitHub](https://github.com/Mikroways/argo-gitops-demo-example/). El README del
repositorio documenta cuáles son los pasos a seguir para replicar el ambiente,
creando un cluster Kubernetes basado en [kind](https://kind.sigs.k8s.io/), donde
se desplegará ArgoCD con una serie de servicios que permiten evidenciar el flujo
con ejemplos concretos. Además del repositorio, es importante tomar conocimiento
de los charts que dan vida al flujo:

* [mikroways/argo-project](https://github.com/Mikroways/argo-gitops-flow/tree/main/charts/argo-project)
* [mikroways/argo-base-app](https://github.com/Mikroways/argo-gitops-flow/tree/main/charts/argo-base-app)

Luego, las aplicaciones que se desplegarán mostrarán una serie de escenarios que
se apoyan en [otro repositorio también
template](https://github.com/Mikroways/argo-gitops-private-template),
que conviene versionarlo de forma privada tanto en GitHub como GitLab para
completar pruebas con ambas plataformas.

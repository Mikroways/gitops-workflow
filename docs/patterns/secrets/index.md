# Datos sensibles

Es muy importante cuando trabajamos con GitOps el versionado de datos que son
inherentemente sensibles. Como es de imaginar, versionar estos datos en Git es
un **antipatrón**. Por tanto, mencionaremos aquí una serie de herramientas que
nos permiten trabajar con datos cifrados en vez de texto claro para poder
versionar este tipo de información. Las herramientas más conocidas para cifrar
datos son:

* [Helm secrets](https://github.com/jkroepke/helm-secrets)
* [Sealed secrets](https://github.com/bitnami-labs/sealed-secrets)
* [External secrets](https://external-secrets.io/)
* [Secret store CSI](https://secrets-store-csi-driver.sigs.k8s.io/)

!!! info
    Además de las herramientas antes mencionadas, existen operadores que
    gestionan backing services y en su flujo de trabajo se encargan de crear
    secretos de Kubernetes que no se versionan y son consumidos luego
    directamente por los pods. Entonces, de esta forma se minimiza la necesidad
    de versionar datos sensibles. Sin embargo, esta práctica depende de varios
    factores y por tanto no es siempre posible.

Usar cualquier alternativa para el cifrado de datos sensibles es un **patrón**
para el adecuado trabajo con GitOps.

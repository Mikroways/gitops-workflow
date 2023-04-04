# GitOps Workflow
Un flujo de trabajo de GitOps, explicado.

# Para instalar localmente

Es una serie breve de instrucciones para quienes quieran correr esta guía localmente. Se asume un uso de una terminal de tipo *-sh (bash, szh, etc). 

Aseguresé de un ambiente virtual con una versión reciente de python3, en nuestro caso usamos [pyenv](), [direnv]() y un archivo .envrc con el contenido `layout pyenv 3.9.9`.

Instale las dependencias con `pip install -r requirements` que se encuentra en la raiz del directorio.

Luego se sirve localmente con `mkdocs serve`. Encontrará la instancia corriendo localmente por defecto en la dirección [http://127.0.0.1:8000](http://127.0.0.1:8000).

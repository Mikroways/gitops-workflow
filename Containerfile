FROM python:3.10-alpine as mkdocs
WORKDIR /app
COPY requirements.txt /app
RUN pip install -r requirements.txt
COPY . /app
RUN mkdocs build -d static/

FROM ghcr.io/nginxinc/nginx-unprivileged:1.25-alpine
COPY container/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY --from=mkdocs --chown=nginx:root /app/static /usr/share/nginx/html

FROM python:3.10-alpine as mkdocs
WORKDIR /app
COPY requirements.txt /app
RUN pip install -r requirements.txt
COPY . /app
RUN mkdocs build -d static/

FROM ghcr.io/nginxinc/nginx-unprivileged:1.25-alpine
RUN sed -i 's/#error_page/error_page/' /etc/nginx/conf.d/default.conf
COPY --from=mkdocs --chown=nginx:root /app/static /usr/share/nginx/html

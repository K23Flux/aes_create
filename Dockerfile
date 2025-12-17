# 使用最轻量的 Nginx 镜像
FROM nginx:alpine

# 把当前目录下的 index.html 复制到容器里
COPY . /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80
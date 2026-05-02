# 使用最轻量的 Nginx 镜像
FROM nginx:alpine

# 只发布静态页面，避免把脚本或仓库文件复制进镜像
COPY html/ /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80

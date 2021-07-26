FROM nginx:alpine

COPY ./volumed/etc/nginx/conf.d/* ./etc/nginx/conf.d/
COPY ./volumed/etc/nginx/ssl/* ./etc/nginx/ssl/

EXPOSE 80
EXPOSE 443
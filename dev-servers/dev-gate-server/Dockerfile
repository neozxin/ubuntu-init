FROM nginx:alpine

#### Switch to faster repository mirrors
ARG path_apkrepos="/etc/apk/repositories"
RUN cp "${path_apkrepos}" "${path_apkrepos}_BAK" \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' "${path_apkrepos}"

RUN apk --update --upgrade add openssl

COPY ./volumed/etc/nginx/conf.d/* ./etc/nginx/conf.d/
# COPY ./volumed/etc/nginx/ssl/* ./etc/nginx/ssl/

WORKDIR "/etc/nginx/ssl"
WORKDIR "/etc/nginx"

#### Generate certificate
RUN var__path_my_all_server_nginx_cert="/etc/nginx/ssl/self.pem" \
    && openssl req -new -x509 -days 36500 -nodes \
      -out "${var__path_my_all_server_nginx_cert}" \
      -keyout "${var__path_my_all_server_nginx_cert}" \
      -subj "/C=US/ST=California/L=San Diego/O=Development/OU=Dev/CN=example.com"

EXPOSE 80 443
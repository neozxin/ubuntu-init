#!/bin/sh

echo ${var__is_verbose:="y"}
echo ${var__is_docker_build:=""}

do__action() {
  while true; do
    echo ${var__path_host_dir:="$(cd `dirname $0` && pwd)"}
    local var__path_host_dir_volumed="${var__path_host_dir}/volumed"

    local var__path_dckr_my_all_server_nginx_ssl="/etc/nginx/ssl"
    local var__filename_my_all_server_nginx_cert="self.pem"

    local var__path_my_all_server_nginx_cert="${var__path_host_dir_volumed}/${var__path_dckr_my_all_server_nginx_ssl}/${var__filename_my_all_server_nginx_cert}"

    mkdir -p "$(dirname "${var__path_my_all_server_nginx_cert}")" || break
    openssl req -new -x509 -days 36500 -nodes -out "${var__path_my_all_server_nginx_cert}" -keyout "${var__path_my_all_server_nginx_cert}" \
      -subj "/C=US/ST=California/L=San Diego/O=Development/OU=Dev/CN=example.com" || break

    [ "y" = "${var__is_docker_build}" ] && {
      docker build . --file "Dockerfile" --tag "neozxin/dev-gate-server:latest" || break
    }

    return 0
  done
  return 1
}

main() {
  do__action "$@" && return 0
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ "y" = "${var__is_verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"

#!/bin/sh
## ================ RKE Init Scripts: 1.0.190110 ================
printArgs() {
  local IFS="|"
  printf -- "\nCommand arguments separated by '|': $*\n"
}
enterOrDefault() {
  local var_prompt="$1"
  local var_default="$2"
  local var_var
  read -p "${var_prompt} [${var_default}]: " var_var
  printf -- "${var_var:-"${var_default}"}"
}

init__RkeServer() {
  printf -- "\n[$(date) @ X] Info: init RKE Server\n"
  local f && for f in "dockerimg@rke@server"*; do cat "$f" | docker load; done
  docker run -d --restart=unless-stopped --name "rke-server" -p 80:80 -p 443:443 "rancher/rancher:v2.1.5" \
  || return 1
}

init__RkeNode() {
  printf -- "\n[$(date) @ X] Info: init RKE Node\n"
  local f && for f in "dockerimg@rke@node"*; do cat "$f" | docker load; done
}

main() {
  printArgs "$@"
  while true; do
    [ "server" = "$1" ] && {
      init__RkeServer || break
    }
    [ "node" = "$1" ] && {
      init__RkeNode || break
    }
    [ -z "$1" ] && {
      printf -- "\nUsage example: $0 server\n"
      printf -- "\nUsage example: $0 node\n"
    }
    printf -- "\n[$(date) @ X] Success!\n"
    return
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"

#!/bin/sh
## ================ OS Init Scripts: 1.0.190107 ================
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

enterNewHostname() {
  local var_hostnameOld="$(hostname)"
  local var_hostnameNew="$(enterOrDefault "Please enter hostname" "${var_hostnameOld}")"
  [ "${var_hostnameOld}" = "${var_hostnameNew}" ] \
  && printf -- "" \
  || printf -- "${var_hostnameNew}"
}

addIpHostLines() {
  local IFS="|"
  local var_hostFile="/etc/hosts"
  local var_hostLines
  printf -- "\n\nCurrent ip-host mapping lines:\n" | cat - "${var_hostFile}"
  while true; do
    var_hostLines="$(enterOrDefault "Please add any ip-host mapping lines if needed(format: 'ip1 host1|ip2 host2|ip3 host3' or empty to finish)")"
    [ -z "${var_hostLines}" ] && break
    # IFS=';' read -ra var_hostLines_array <<< "${var_hostLines}"
    sed -i "1s/^/$(echo "${var_hostLines}" | sed "s/|/\\\n/g")\n/" "${var_hostFile}" || break
  done
  [ -z "${var_hostLines}" ] \
  && printf -- "\n\nCurrent ip-host mapping lines:\n" | cat - "${var_hostFile}" \
  || return 1
}

init__Linux_Alpine() {
  printf -- "\n[$(date) @ X] Info: init Linux - Alpine\n" \
  && {
    # Replace apk repositories:
    local var_sysVer="$(enterOrDefault "Please enter OS version" "$(cat /etc/alpine-release)")"
    local var_reposFile="/etc/apk/repositories"
    cp "${var_reposFile}" "${var_reposFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC" \
    && printf -- "\n" > "${var_reposFile}" \
    && printf -- "\n#/media/cdrom/apks" >> "${var_reposFile}" \
    && printf -- "\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/v${var_sysVer}/main" >> "${var_reposFile}" \
    && printf -- "\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/v${var_sysVer}/community" >> "${var_reposFile}" \
    && printf -- "\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/edge/main" >> "${var_reposFile}" \
    && printf -- "\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community" >> "${var_reposFile}" \
    && printf -- "\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/edge/testing" >> "${var_reposFile}" \
    && printf -- "\n" >> "${var_reposFile}"
  } \
  && {
    # Update system:
    apk update \
    && apk upgrade
  } \
  && {
    # Replace ssh config:
    local var_sshCfgFile="/etc/ssh/sshd_config"
    local var_sshPermitRootLogin="PermitRootLogin yes"
    cp "${var_sshCfgFile}" "${var_sshCfgFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC" \
    && grep -qx "${var_sshPermitRootLogin}" "${var_sshCfgFile}" || printf -- "\n\n${var_sshPermitRootLogin}\n" >> "${var_sshCfgFile}"
  } \
  && {
    local var_hostname="$(enterNewHostname)"
    [ -z "${var_hostname}" ] || {
      setup-hostname "${var_hostname}"
    }
  } \
  && addIpHostLines \
  && {
    # Add Docker:
    apk add docker \
    && rc-update add docker boot \
    && service docker start
  } \
  || return 1
}

init__Linux_Ubuntu() {
  printf -- "\n[$(date) @ X] Info: init Linux - Ubuntu\n" \
  && mkdir -p /etc/cloud && touch /etc/cloud/cloud-init.disabled \
  && apt update \
  && apt upgrade -y \
  && {
    local var_hostname="$(enterNewHostname)"
    [ -z "${var_hostname}" ] || {
      # sed -i '/preserve_hostname: false/c\preserve_hostname: true' "/etc/cloud/cloud.cfg"
      hostnamectl set-hostname "${var_hostname}"
    }
  } \
  && addIpHostLines \
  && apt install -y docker.io \
  || return 1
}

main() {
  printArgs "$@"
  while true; do
    [ "linux.alpine" = "$1" ] && {
      init__Linux_Alpine || break
    }
    [ "linux.ubuntu" = "$1" ] && {
      init__Linux_Ubuntu || break
    }
    [ -z "$1" ] && {
      printf -- "\nUsage example: $0 linux.alpine\n"
      printf -- "\nUsage example: $0 linux.ubuntu\n"
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

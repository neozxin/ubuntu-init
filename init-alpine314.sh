#!/bin/sh

echo ${var__is_verbose:="y"}
echo ${var__cmd_types:="type__init_os|type__inst_dev"}
# echo ${var__env_path:="$HOME/.profile"}
echo ${var__inst_pkg_path:="$HOME/Downloads/_shares"}
# echo ${var__inst_exec_path:="/opt"}
echo ${var__init_os__virtualbox_guest__apply:="y"}
echo  ${var__init_os__virtualbox_guest__nat_guest_name_local:="guest.mynat.local"}
echo  ${var__init_os__virtualbox_guest__nat_guest_ip:="10.0.2.15"}
echo  ${var__init_os__virtualbox_guest__nat_host_name_local:="host.mynat.local"}
echo  ${var__init_os__virtualbox_guest__nat_host_ip:="10.0.2.2"}
echo ${var__init_os__proxy__apply:=""}
echo  ${var__init_os__proxy__ip:="10.41.77.158"} #10.42.70.226"}
echo  ${var__init_os__proxy__port:="8080"}
echo  ${var__init_os__proxy__username:=""}
echo  ${var__init_os__proxy__password:=""}
echo  ${var__init_os__proxy__host_name_local:="internet.myproxy.local"}


do__action() {
  local local__cmd_type="$1"
  while true; do
    if [ "type__init_os" = "${local__cmd_type}" ]; then

      printf -- "\n[$(date) @ X] ================ 初始化 Alpine 3.14 系统环境: 3.0.210730 ================\n"

      #### 配置 proxy
      if [ "y" = "${var__init_os__proxy__apply}" ]; then
        local local__host_proxy="${var__init_os__proxy__host_name_local}:${var__init_os__proxy__port}"
        [ -n "${var__init_os__proxy__username}" ] && local__host_proxy="${var__init_os__proxy__username}:${var__init_os__proxy__password}@${local__host_proxy}"
        local local__url_proxy=""
        [ -n "${var__init_os__proxy__ip}" ] && local__url_proxy="http://${local__host_proxy}/"
        #### proxy hostname
        local local__path_etc_hosts="/etc/hosts"
        local local__line_etc_hosts_proxy1="${var__init_os__proxy__ip} ${var__init_os__proxy__host_name_local}\n"
        [ -z "${var__init_os__proxy__ip}" ] || printf -- "${local__line_etc_hosts_proxy1}" >> "${local__path_etc_hosts}" || break
        #### general proxy
        local local__path_env="/etc/profile.d/myenvs_$(date -u +'%Y-%m-%dT%H-%M-%S')UTC"
        local local__no_proxy_items=".local,localhost,127.0.0.1,::1"
        local local__lines_env_proxy1="\n\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}export http_proxy=${local__url_proxy}\nHTTP_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}export https_proxy=${local__url_proxy}\nHTTPS_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}export ftp_proxy=${local__url_proxy}\nFTP_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}export no_proxy=${local__no_proxy_items}\nNO_PROXY=${local__no_proxy_items}\n"
        printf -- "${local__lines_env_proxy1}" >> "${local__path_env}" || break
      fi

      #### 配置 apk repositories
      local_apkReposFile="/etc/apk/repositories"
      # #### Add more apk repositories:
      # local_apkReposFile__repo1="http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community"
      # grep -qx "${local_apkReposFile__repo1}" "${local_apkReposFile}" || echo "${local_apkReposFile__repo1}" >> "${local_apkReposFile}" || break
      #### Replace apk repositories:
      cp "${local_apkReposFile}" "${local_apkReposFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC"
      printf -- "${var__apkReposFileContent}" > "${local_apkReposFile}" || break

      #### Update system:
      apk update || break
      apk upgrade || break
      # apk add wget # To make sure authentication is supported

      #### Replace ssh config:
      local local_sshCfgFile="/etc/ssh/sshd_config"
      local local_sshCfgFile__PermitRootLogin="PermitRootLogin yes"
      local local_sshCfgFile__X11Forwarding="X11Forwarding yes"
      local local_sshCfgFileAddContent=""
      cp "${local_sshCfgFile}" "${local_sshCfgFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC" || break
      grep -qx "${local_sshCfgFile__PermitRootLogin}" "${local_sshCfgFile}" || local_sshCfgFileAddContent="${local_sshCfgFileAddContent}${local_sshCfgFile__PermitRootLogin}\n"
      grep -qx "${local_sshCfgFile__X11Forwarding}" "${local_sshCfgFile}" || local_sshCfgFileAddContent="${local_sshCfgFileAddContent}${local_sshCfgFile__X11Forwarding}\n"
      [ -z "${local_sshCfgFileAddContent}" ] || printf -- "\n\n\n${local_sshCfgFileAddContent}\n" >> "${local_sshCfgFile}" || break
      service sshd restart || break

      #### Add user:
      local local_newUser="zx"
      id -u "$local_newUser" &>/dev/null || adduser --disabled-password --gecos "" "$local_newUser" || break
      echo "$local_newUser":"$local_newUser" | chpasswd || break

      #### 授予 VirtualBox Share Folder 当前用户的访问权限： https://www.htpcbeginner.com/mount-virtualbox-shared-folder-on-ubuntu-linux/
      #### VirtualBox VM 需要先安装支持套件: menu - Devices - Insert Guest Additions CD image...
      if [ "y" = "${var__init_os__virtualbox_guest__apply}" ]; then
        # apk add virtualbox-guest-additions virtualbox-guest-modules-virt || break #https://download.virtualbox.org/virtualbox/5.2.6/
        getent group vboxsf && { adduser "$local_newUser" vboxsf || break; }
        local local__path_etc_hosts="/etc/hosts"
        local local__lines_etc_hosts=""
        local__lines_etc_hosts="${local__lines_etc_hosts}${var__init_os__virtualbox_guest__nat_guest_ip} ${var__init_os__virtualbox_guest__nat_guest_name_local}\n"
        local__lines_etc_hosts="${local__lines_etc_hosts}${var__init_os__virtualbox_guest__nat_host_ip} ${var__init_os__virtualbox_guest__nat_host_name_local}\n"
        [ -z "${var__init_os__virtualbox_guest__nat_host_ip}" ] || printf -- "${local__lines_etc_hosts}" >> "${local__path_etc_hosts}" || break
        # reboot
      fi

      #### Add Docker: ref: http://janhapke.com/blog/installing-docker-daemon-on-alpine-linux/
      docker -v || apk add docker || break
      rc-update add docker boot || break
      service docker start || break
      # #### set registry
      # local local__path_docker_daemon="/etc/docker/daemon.json"
      # local local__lines_docker_daemon="\n\n{ \"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"] }\n"
      # [ -z "${local__path_docker_daemon}" ] || printf -- "${local__lines_docker_daemon}" > "${local__path_docker_daemon}" || break
      #### set user group
      getent group docker || addgroup -S docker || break
      adduser "$local_newUser" docker || break

      #### Load any saved Docker images:
      [ -f dockerimg@* ] && { for f in dockerimg@*; do cat $f | docker load; done; }

      # #### Run container remote desktop: ref: https://vocon-it.com/2016/04/28/running-gui-apps-with-docker-for-remote-access/
      # docker run --name "zx-vnc-container" -p 5901:5901 -p 6901:6901 --restart=always -v "/usr/src/0.host-share":"/usr/src/0.host-share" -d "consol/ubuntu-xfce-vnc:1.4.0"

      printf -- "\n[$(date) @ X] Success! Please reboot to finish\n"

    elif [ "type__inst_dev" = "${local__cmd_type}" ]; then

      printf -- "\n\n"

    else

      printf -- "\nUsage: config variables before executing me\n"

    fi
    return 0
  done
  return 1
}


var__apkReposFileContent="$(cat << 'EOF'

#/media/cdrom/apks
http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/main
http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/community
# http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/main
# http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community
# http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/testing

EOF
)"


main() {
  # cd $(cd `dirname $0` && pwd)
  local IFS="|"
  local local__cmd_type
  for local__cmd_type in ${var__cmd_types}; do
    do__action "${local__cmd_type}" || break
    local__cmd_type=""
  done
  [ -z "${local__cmd_type}" ] && return 0
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ "y" = "${var__is_verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"

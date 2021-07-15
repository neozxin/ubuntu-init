#!/bin/sh

echo ${var__is_verbose:="y"}
echo ${var__cmd_types:="type__init_os|type__inst_dev"}
# echo ${var__env_path:="$HOME/.profile"}
echo ${var__inst_pkg_path:="$HOME/Downloads/_shares"}
# echo ${var__inst_exec_path:="/opt"}
echo ${var__init_os__virtualbox_guest__apply:="y"}
echo  ${var__init_os__virtualbox_guest__nat_host_name_local:="host.mynat.local"}
echo  ${var__init_os__virtualbox_guest__nat_host_ip:="10.0.2.2"}
echo ${var__init_os__proxy__apply:=""}
echo  ${var__init_os__proxy__ip:="10.41.77.158"}
echo  ${var__init_os__proxy__port:="8080"}
echo  ${var__init_os__proxy__username:=""}
echo  ${var__init_os__proxy__password:=""}
echo  ${var__init_os__proxy__host_name_local:="internet.myproxy.local"}

do__func_add_file_content() {
  local local__type="$(printf -- "$1" | cut -c 2-)"
  local local__path="$2"
  local local__content="$3"
  local local__is_sudo="$(printf -- "$1" | cut -c -1)"
  while true; do
    local local__path_my_temp_file="$HOME/my_temp_file_$(date +%s%N)"
    touch "${local__path_my_temp_file}" || break
    [ "-" = "${local__is_sudo}" ] && { mkdir -p "$(dirname "${local__path}")" || break; }
    [ "+" = "${local__is_sudo}" ] && { sudo mkdir -p "$(dirname "${local__path}")" || break; }
    if [ "prepend" = "${local__type}" ]; then
      printf -- "${local__content}" >> "${local__path_my_temp_file}" || break
      [ -f "${local__path}" ] && { sudo cat "${local__path}" >> "${local__path_my_temp_file}" || break; }
    elif [ "append" = "${local__type}" ]; then
      [ -f "${local__path}" ] && { sudo cat "${local__path}" >> "${local__path_my_temp_file}" || break; }
      printf -- "${local__content}" >> "${local__path_my_temp_file}" || break
    fi
    sudo rm -rf "${local__path}" || break
    sudo mv "${local__path_my_temp_file}" "${local__path}" || break
    [ "+" = "${local__is_sudo}" ] && { sudo chown root:root "${local__path}" || break; }
    return
  done
  return 1
}

do__func_download_file() {
  local local__download_url="$1"
  local local__pkg_filename="$2"
  local local__pkg_dir="$3"
  echo ${local__pkg_dir:="."}
  while true; do
    [ -f "${local__pkg_dir}/${local__pkg_filename}" ] || wget "${local__download_url}" -P "${local__pkg_dir}/"
    [ -f "${local__pkg_dir}/${local__pkg_filename}" ] || break
    return
  done
  return 1
}

do__action() {
  local local__cmd_type="$1"
  while true; do
    if [ "type__init_os" = "${local__cmd_type}" ]; then

      printf -- "\n[$(date) @ X] ================ 初始化 Ubuntu 20.04-LTS 系统环境: 3.0.210702 ================\n"

      # 配置 proxy
      if [ "y" = "${var__init_os__proxy__apply}" ]; then
        local local__host_proxy="${var__init_os__proxy__host_name_local}:${var__init_os__proxy__port}"
        [ -n "${var__init_os__proxy__username}" ] && local__host_proxy="${var__init_os__proxy__username}:${var__init_os__proxy__password}@${local__host_proxy}"
        local local__url_proxy=""
        [ -n "${var__init_os__proxy__ip}" ] && local__url_proxy="http://${local__host_proxy}/"
        # proxy hostname
        local local__path_etc_hosts="/etc/hosts"
        local local__line_etc_hosts_proxy1="${var__init_os__proxy__ip} ${var__init_os__proxy__host_name_local}\n"
        [ -n "${var__init_os__proxy__ip}" ] && { do__func_add_file_content "+prepend" "${local__path_etc_hosts}" "${local__line_etc_hosts_proxy1}" || break; }
        # general proxy
        local local__path_env="/etc/environment"
        local local__no_proxy_items=".local,localhost,127.0.0.1,::1"
        local local__lines_env_proxy1="\n\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}http_proxy=${local__url_proxy}\nHTTP_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}https_proxy=${local__url_proxy}\nHTTPS_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}ftp_proxy=${local__url_proxy}\nFTP_PROXY=${local__url_proxy}\n"
        local__lines_env_proxy1="${local__lines_env_proxy1}no_proxy=${local__no_proxy_items}\nNO_PROXY=${local__no_proxy_items}\n"
        do__func_add_file_content "+append" "${local__path_env}" "${local__lines_env_proxy1}" || break
        # apt proxy
        local local__path_apt_proxy="/etc/apt/apt.conf.d/80proxy"
        local local__lines_apt_proxy1="\n\n"
        local__lines_apt_proxy1="${local__lines_apt_proxy1}Acquire::http::proxy \"${local__url_proxy}\";\n"
        local__lines_apt_proxy1="${local__lines_apt_proxy1}Acquire::https::proxy \"${local__url_proxy}\";\n"
        local__lines_apt_proxy1="${local__lines_apt_proxy1}Acquire::ftp::proxy \"${local__url_proxy}\";\n"
        do__func_add_file_content "+append" "${local__path_apt_proxy}" "${local__lines_apt_proxy1}" || break
        # snap proxy
        sudo snap set system proxy.http="${local__url_proxy}" || break
        sudo snap set system proxy.https="${local__url_proxy}" || break
      fi

      # 准备依赖环境
      sudo apt-get -y update || break
      sudo apt-get -yf install || break

      # 授予 VirtualBox Share Folder 当前用户的访问权限： https://www.htpcbeginner.com/mount-virtualbox-shared-folder-on-ubuntu-linux/
      # VirtualBox VM 需要先安装支持套件: menu - Devices - Insert Guest Additions CD image...
      if [ "y" = "${var__init_os__virtualbox_guest__apply}" ]; then
        # sudo apt-get install virtualbox-guest-dkms || break #https://download.virtualbox.org/virtualbox/5.2.6/
        getent group vboxsf && { sudo usermod -a -G vboxsf $USER || break; }
        local local__path_etc_hosts="/etc/hosts"
        local local__line_etc_hosts_host1="${var__init_os__virtualbox_guest__nat_host_ip} ${var__init_os__virtualbox_guest__nat_host_name_local}\n"
        [ -n "${var__init_os__virtualbox_guest__nat_host_ip}" ] && { do__func_add_file_content "+prepend" "${local__path_etc_hosts}" "${local__line_etc_hosts_host1}" || break; }
        # sudo reboot
      fi

      # # 默认 root 权限配置
      local local__path_my_sudoers="$HOME/mysudoers_$(date +%s%N)"
      sudo printf -- "\n\n$USER ALL=(ALL:ALL) NOPASSWD: ALL\n" > "${local__path_my_sudoers}" || break
      sudo chown root:root "${local__path_my_sudoers}" || break
      sudo chmod 0440 "${local__path_my_sudoers}" || break
      sudo rm -rf "/etc/sudoers.d/${local__path_my_sudoers}" || break
      sudo mv "${local__path_my_sudoers}" "/etc/sudoers.d/" || break

      # 部分设置在重启后生效
      sudo apt-get -yf install || break

      printf -- "\n[$(date) @ X] Success! Please reboot to finish\n"

    elif [ "type__inst_dev" = "${local__cmd_type}" ]; then

      printf -- "\n[$(date) @ X] ================ 安装 Ubuntu 20.04-LTS 工具应用: 3.0.210702 ================\n"

      # 准备依赖环境
      sudo apt-get -y update || break
      sudo apt-get -yf install || break

      # 准备 software suites installation repos
      [ -n "${var__inst_pkg_path}" ] && { mkdir -p "${var__inst_pkg_path}" || break; }
      [ -n "${var__inst_exec_path}" ] && { mkdir -p "${var__inst_exec_path}" || break; }

      ##### 基础依赖 #####
      # 安装 Git
      git --version || { sudo apt-get -y install git || break; }

      # 安装 Samba
      samba -V || { sudo apt-get -y install samba || break; }

      # 安装 SSH
      ssh -V || { sudo apt-get -y install ssh || break; }

      ##### 开发依赖 #####
      # 安装 Docker
      docker -v || {
        # # snap install
        # sudo snap install docker || break
        # # script install
        # wget -qO- http://get.docker.io | sh || break
        # pkg install
        local local__pkg_filename_containerd="containerd.io_1.4.6-1_amd64.deb"
        local local__pkg_filename_docker_ce_cli="docker-ce-cli_20.10.7~3-0~ubuntu-focal_amd64.deb"
        local local__pkg_filename_docker_ce="docker-ce_20.10.7~3-0~ubuntu-focal_amd64.deb"
        do__func_download_file "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/${local__pkg_filename_containerd}" "${local__pkg_filename_containerd}" "${var__inst_pkg_path}" || break
        sudo dpkg -i "${var__inst_pkg_path}/${local__pkg_filename_containerd}" || sudo apt-get -yf install || break
        do__func_download_file "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/${local__pkg_filename_docker_ce_cli}" "${local__pkg_filename_docker_ce_cli}" "${var__inst_pkg_path}" || break
        sudo dpkg -i "${var__inst_pkg_path}/${local__pkg_filename_docker_ce_cli}" || sudo apt-get -yf install || break
        do__func_download_file "https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/${local__pkg_filename_docker_ce}" "${local__pkg_filename_docker_ce}" "${var__inst_pkg_path}" || break
        sudo dpkg -i "${var__inst_pkg_path}/${local__pkg_filename_docker_ce}" || sudo apt-get -yf install || break
        # set user group
        getent group docker || sudo groupadd docker || break
        sudo usermod -aG docker $USER || break
      }
      if [ "y" = "${var__init_os__proxy__apply}" ]; then
        local local__host_proxy="${var__init_os__proxy__host_name_local}:${var__init_os__proxy__port}"
        [ -n "${var__init_os__proxy__username}" ] && local__host_proxy="${var__init_os__proxy__username}:${var__init_os__proxy__password}@${local__host_proxy}"
        local local__url_proxy=""
        [ -n "${var__init_os__proxy__ip}" ] && local__url_proxy="http://${local__host_proxy}/"
        local local__no_proxy_items=".local,localhost,127.0.0.1,::1"
        local local__path_docker_proxy="/etc/systemd/system/docker.service.d/http-proxy.conf"
        local local__lines_docker_proxy1="\n\n"
        local__lines_docker_proxy1="${local__lines_docker_proxy1}[Service]\n"
        local__lines_docker_proxy1="${local__lines_docker_proxy1}Environment=\"HTTP_PROXY=${local__url_proxy}\"\n"
        local__lines_docker_proxy1="${local__lines_docker_proxy1}Environment=\"HTTPS_PROXY=${local__url_proxy}\"\n"
        local__lines_docker_proxy1="${local__lines_docker_proxy1}Environment=\"NO_PROXY=${local__no_proxy_items}\"\n"
        # set proxy
        do__func_add_file_content "+append" "${local__path_docker_proxy}" "${local__lines_docker_proxy1}" || break
        local local__path_docker_daemon="/etc/docker/daemon.json"
        local local__lines_docker_daemon="\n\n{ \"registry-mirrors\": [\"https://9cpn8tt6.mirror.aliyuncs.com\"] }\n"
        # set registry
        do__func_add_file_content "+append" "${local__path_docker_daemon}" "${local__lines_docker_daemon}" || break
      fi

      # 安装 VSCode
      code -v || {
        # snap install
        sudo snap install code --classic || break
        # # pkg install
        # local local__pkg_filename="code_1.43.2-1585036376_amd64.deb"
        # do__func_download_file "https://vscode.cdn.azure.cn/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/${local__pkg_filename}" "${local__pkg_filename}" "${var__inst_pkg_path}" || break
        # sudo dpkg -i "${var__inst_pkg_path}/${local__pkg_filename}" || sudo apt-get -yf install || break
      }

      # 安装 NodeJS
      node -v || {
        # snap install
        sudo snap install node --classic --channel=14 || break
        # # apt install
        # curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - && sudo apt-get install -y nodejs || break
        # # bin install
        # local local__pkg_filename="node-v14.17.3-linux-x64.tar.xz"
        # do__func_download_file "https://nodejs.org/dist/v14.17.3/${local__pkg_filename}" "${local__pkg_filename}" "${var__inst_pkg_path}" || break
        # sudo tar -zxvf "${var__inst_pkg_path}/${local__pkg_filename}" -C "${var__inst_exec_path}" || break
        # local local__lines_env="\n\nexport PATH=\"${var__inst_exec_path}/node-v14.17.3-linux-x64/bin\":\"$PATH\""
        # do__func_add_file_content "+append" "${var__env_path}" "${local__lines_env}" || break
      }
      npm -v || { sudo apt-get -y install npm || break; }
      if [ "y" = "${var__init_os__proxy__apply}" ]; then
        local local__path_npmrc="$HOME/.npmrc"
        local local__host_proxy="${var__init_os__proxy__host_name_local}:${var__init_os__proxy__port}"
        [ -n "${var__init_os__proxy__username}" ] && local__host_proxy="${var__init_os__proxy__username}:${var__init_os__proxy__password}@${local__host_proxy}"
        local local__url_proxy=""
        [ -n "${var__init_os__proxy__ip}" ] && local__url_proxy="http://${local__host_proxy}/"
        local local__lines_npmrc_proxy1="\n\n"
        local__lines_npmrc_proxy1="${local__lines_npmrc_proxy1}proxy = ${local__url_proxy}\n"
        local__lines_npmrc_proxy1="${local__lines_npmrc_proxy1}https-proxy = ${local__url_proxy}\n"
        local__lines_npmrc_proxy1="${local__lines_npmrc_proxy1}registry = http://registry.npmjs.org/\n"
        local__lines_npmrc_proxy1="${local__lines_npmrc_proxy1}##### registry = https://registry.npm.taobao.org/\n"
        do__func_add_file_content "-append" "${local__path_npmrc}" "${local__lines_npmrc_proxy1}" || break
        # sudo npm config set proxy "${local__url_proxy}" || break
        # sudo npm config set https-proxy "${local__url_proxy}" || break
        # sudo npm config set registry 'http://registry.npmjs.org/' || break
        sudo npm config list || break
      fi

      # 部分设置在重启后生效
      sudo apt-get -yf install || break

      printf -- "\n[$(date) @ X] Success!\n"

    else

      printf -- "\nUsage: config variables before executing me\n"

    fi
    return
  done
  return 1
}

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

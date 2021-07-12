#!/bin/sh

echo ${var__is_verbose:="y"}
echo ${var__cmd_types:="type__init_os|type__inst_dev"}
# echo ${var__env_path:="$HOME/.profile"}
# echo ${var__inst_pkg_path:="$HOME/Downloads/_shares"}
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
  local local__type="$1"
  local local__path="$2"
  local local__content="$3"
  while true; do
    if [ "prepend" = "${local__type}" ]; then
      local local__path_my_temp_file="$HOME/my_temp_file_$(date +%s%N)"
      printf -- "$3\n" > "${local__path_my_temp_file}" || break
      [ -f "${local__path}" ] || sudo touch "${local__path}" || break
      cat "${local__path}" >> "${local__path_my_temp_file}" || break
      sudo mv "${local__path_my_temp_file}" "${local__path}" || break
    elif [ "append" = "${local__type}" ]; then
      [ -f "${local__path}" ] || sudo touch "${local__path}" || break
      sudo sh -c "printf -- '\n${local__content}' >> '${local__path}'" || break
    fi
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
        local local__path_etc_hosts="/etc/hosts"
        local local__line_etc_hosts_proxy1="${var__init_os__proxy__ip} ${var__init_os__proxy__host_name_local}\n"
        [ -n "${var__init_os__proxy__ip}" ] && { do__func_add_file_content "prepend" "${local__path_etc_hosts}" "${local__line_etc_hosts_proxy1}" || break; }
        # general proxy
        local local__path_env="/etc/environment"
        local local__no_proxy_items=".local,localhost,127.0.0.1,::1"
        local local__line_env_proxy1_1="http_proxy=${local__url_proxy}\nHTTP_PROXY=${local__url_proxy}\n"
        local local__line_env_proxy1_2="https_proxy=${local__url_proxy}\nHTTPS_PROXY=${local__url_proxy}\n"
        local local__line_env_proxy1_3="ftp_proxy=${local__url_proxy}\nFTP_PROXY=${local__url_proxy}\n"
        local local__line_env_proxy1_4="no_proxy=${local__no_proxy_items}\nNO_PROXY=${local__no_proxy_items}\n"
        local local__lines_env_proxy1="\n${local__line_env_proxy1_1}${local__line_env_proxy1_2}${local__line_env_proxy1_3}${local__line_env_proxy1_4}"
        do__func_add_file_content "append" "${local__path_env}" "${local__lines_env_proxy1}" || break
        # apt proxy
        local local__path_apt_proxy="/etc/apt/apt.conf.d/80proxy"
        local local__line_apt_proxy1_1="Acquire::http::proxy \"${local__url_proxy}\";\n"
        local local__line_apt_proxy1_2="Acquire::https::proxy \"${local__url_proxy}\";\n"
        local local__line_apt_proxy1_3="Acquire::ftp::proxy \"${local__url_proxy}\";\n"
        local local__lines_apt_proxy1="\n${local__line_apt_proxy1_1}${local__line_apt_proxy1_2}${local__line_apt_proxy1_3}"
        do__func_add_file_content "append" "${local__path_apt_proxy}" "${local__lines_apt_proxy1}" || break
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
        [ -n "${var__init_os__virtualbox_guest__nat_host_ip}" ] && { do__func_add_file_content "prepend" "${local__path_etc_hosts}" "${local__line_etc_hosts_host1}" || break; }
        # sudo reboot
      fi

      # # 默认 root 权限配置
      # local local__path_my_sudoers="$HOME/mysudoers_$(date +%s%N)"
      # sudo printf -- "\n\n$USER ALL=(ALL:ALL) NOPASSWD: ALL\n" > "${local__path_my_sudoers}" || break
      # sudo chown root:root "${local__path_my_sudoers}" || break
      # sudo chmod 0440 "${local__path_my_sudoers}" || break
      # sudo rm -rf "/etc/sudoers.d/${local__path_my_sudoers}" || break
      # sudo mv "${local__path_my_sudoers}" "/etc/sudoers.d/" || break

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
      # 安装 VSCode
      code -v || {
        sudo snap install code --classic || break
        # local local__pkg_filename="code_1.43.2-1585036376_amd64.deb"
        # [ -f "${var__inst_pkg_path}/${local__pkg_filename}" ] || wget https://vscode.cdn.azure.cn/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/code_1.43.2-1585036376_amd64.deb -P "${var__inst_pkg_path}/"
        # [ -f "${var__inst_pkg_path}/${local__pkg_filename}" ] || break
        # sudo dpkg -i "${var__inst_pkg_path}/${local__pkg_filename}" || sudo apt-get -yf install || break
      }

      # 安装 NodeJS
      node -v || {
        sudo snap install node --classic --channel=14 || break
        # curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && sudo apt-get install -y nodejs || break
        # local local__pkg_filename="node-v8.1.0-linux-x64.tar.gz"
        # [ -f "${var__inst_pkg_path}/${local__pkg_filename}" ] || wget https://nodejs.org/dist/v8.1.0/node-v8.1.0-linux-x64.tar.gz -P "${var__inst_pkg_path}/"
        # [ -f "${var__inst_pkg_path}/${local__pkg_filename}" ] || break
        # sudo tar -zxvf "${var__inst_pkg_path}/${local__pkg_filename}" -C "${var__inst_exec_path}" || break
        # printf -- "\n" >> "${var__env_path}" || break
        # printf -- "\nexport NODEJS_HOME=\"${var__inst_exec_path}/node-v8.1.0-linux-x64/bin\"" >> "${var__env_path}" || break
        # printf -- '\nexport PATH="$NODEJS_HOME":"$PATH"' >> "${var__env_path}" || break
        # printf -- "\n" >> "${var__env_path}" || break
      }
      npm -v || { sudo apt-get -y install npm || break; }
      if [ "y" = "${var__init_os__proxy__apply}" ]; then
        local local__path_npmrc="$HOME/.npmrc"
        local local__host_proxy="${var__init_os__proxy__host_name_local}:${var__init_os__proxy__port}"
        [ -n "${var__init_os__proxy__username}" ] && local__host_proxy="${var__init_os__proxy__username}:${var__init_os__proxy__password}@${local__host_proxy}"
        local local__url_proxy=""
        [ -n "${var__init_os__proxy__ip}" ] && local__url_proxy="http://${local__host_proxy}/"
        [ -f "${local__path_npmrc}" ] || touch "${local__path_npmrc}" || break
        sudo printf -- "\n" >> "${local__path_npmrc}" || break
        sudo printf -- "\nproxy = ${local__url_proxy}\n" >> "${local__path_npmrc}" || break
        sudo printf -- "\nhttps-proxy = ${local__url_proxy}\n" >> "${local__path_npmrc}" || break
        sudo printf -- "\nregistry = http://registry.npmjs.org/\n" >> "${local__path_npmrc}" || break
        sudo printf -- "\n##### registry = https://registry.npm.taobao.org/\n" >> "${local__path_npmrc}" || break
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

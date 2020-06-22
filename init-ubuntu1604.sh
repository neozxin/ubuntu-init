#!/bin/sh

main() {
  while true; do
    printf -- "\n================ 初始化 Ubuntu Xenial 16.04-LTS 系统环境: 2.0.180903 ================\n"
    cd $(cd `dirname $0` && pwd)
    read -p "Is this for a VirualBox VM (y/n)? " var_VirtualBoxBased
    # read -p "Are you willing to deploy a common software suites installation repository (y/n)? " var_instRepoEngaged
    # var_pathRepo_default=~/"Desktop/Repo"
    # var_urlGitInst_default="https://github.com/neozxin/ubuntu-devinst.git"
    # [ "y" = "${var_instRepoEngaged}" ] && read -p "Enter the parent directory path for where to deploy the repository (leave empty for default: ${var_pathRepo_default})? " var_pathRepo
    # [ -z "${var_pathRepo}" ] && var_pathRepo="${var_pathRepo_default}"
    # [ "y" = "${var_instRepoEngaged}" ] && read -p "Enter the url where the Git repository will be cloned from (leave empty for default: ${var_urlGitInst_default})? " var_urlGitInst
    # [ -z "${var_urlGitInst}" ] && var_urlGitInst="${var_urlGitInst_default}"
    set -x

    # 准备依赖环境
    sudo apt-get -y update
    sudo apt-get -yf install

    # 授予 VirtualBox Share Folder 当前用户的访问权限： https://www.htpcbeginner.com/mount-virtualbox-shared-folder-on-ubuntu-linux/
    # VirtualBox VM 需要先安装支持套件: menu - Devices - Insert Guest Additions CD image...
    [ "y" = "${var_VirtualBoxBased}" ] && {
      # sudo apt-get install virtualbox-guest-dkms || break #https://download.virtualbox.org/virtualbox/5.2.6/
      sudo usermod -a -G vboxsf $USER || break
      # sudo reboot
    }

    # 默认 root 权限配置
    var_pathMySudoers=~/"mysudoers_$(date +%s%N)"
    sudo printf -- "\n\n$USER ALL=(ALL:ALL) NOPASSWD: ALL\n" > "${var_pathMySudoers}" || break
    sudo chown root:root "${var_pathMySudoers}" || break
    sudo chmod 0440 "${var_pathMySudoers}" || break
    sudo rm -rf "/etc/sudoers.d/${var_pathMySudoers}" || break
    sudo mv "${var_pathMySudoers}" "/etc/sudoers.d/" || break

    # # 准备 software suites installation repository
    # [ "y" = "${var_instRepoEngaged}" ] && {
    #   sudo apt-get -y install git
    #   mkdir -p "${var_pathRepo}"
    #   cd "${var_pathRepo}" || break
    #   git clone "${var_urlGitInst}" || break
    # }

    # 安装必要依赖
    # 安装 Git
    sudo apt-get -y install git || break
    # 安装 Samba
    sudo apt-get -y install samba || break
    # 安装 SSH
    sudo apt-get -y install ssh || break

    # 部分设置在重启后生效
    sudo apt-get -yf install
    set +x
    printf -- "\n[$(date) @ X] Success! Please reboot to finish\n"
    return
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"

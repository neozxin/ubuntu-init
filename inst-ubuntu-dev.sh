#!/bin/sh
printf -- "\n================ 搭建 Ubuntu Xenial 16.04-LTS 系统开发环境: 3.1.200610 ================\n"
var_execdir="/opt"
var_envfile="$HOME/.profile"
var_pkgdir="$HOME/Downloads/_inst-pkgs"

inst__linux_ubuntu_with_apt() {
  sudo apt-get -y install "$1" || return 1
}

inst__linux_ubuntu_check_to_install() {
  local var_isInst="$1"
  local var_tipmessage="$2"
  [ "y" = "${var_isInst}" ] || read -p "${var_tipmessage}" var_isInst
  [ "y" = "${var_isInst}" ] || return 1
}

inst__linux_ubuntu_VSCode() {
  inst__linux_ubuntu_check_to_install "$1" "Install VSCode[latest] (y/n)? " || return 0
  sudo snap install code --classic || return 1
  # local var_pkgfilename="code_1.43.2-1585036376_amd64.deb"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget https://vscode.cdn.azure.cn/stable/0ba0ca52957102ca3527cf479571617f0de6ed50/code_1.43.2-1585036376_amd64.deb -P "${var_pkgdir}/"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  # sudo dpkg -i "${var_pkgdir}/${var_pkgfilename}" || sudo apt-get -yf install || return 1
}

inst__linux_ubuntu_GoogleChrome() {
  inst__linux_ubuntu_check_to_install "$1" "Install Google Chrome[latest] (y/n)? " || return 0
  local var_pkgfilename="google-chrome-stable_current_amd64.deb"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P "${var_pkgdir}/"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  sudo dpkg -i "${var_pkgdir}/${var_pkgfilename}" || sudo apt-get -yf install || return 1
}

inst__linux_ubuntu_Docker() {
  inst__linux_ubuntu_check_to_install "$1" "Install Docker[latest] (y/n)? " || return 0
  wget -qO- http://get.docker.io | sh || return 1
  # local var_pkgfilename="docker-ce_17.09.1~ce-0~ubuntu_amd64.deb"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.09.1~ce-0~ubuntu_amd64.deb -P "${var_pkgdir}/"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  # sudo dpkg -i "${var_pkgdir}/${var_pkgfilename}" || sudo apt-get -yf install || return 1
  sudo usermod -aG docker $USER || return 1
  # sudo reboot
}

inst__linux_ubuntu_NodeJS() {
  inst__linux_ubuntu_check_to_install "$1" "Install NodeJS[latest 12.x] (y/n)? " || return 0
  # sudo snap install node --classic --channel=12 || return 1
  curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
  && sudo apt-get install -y nodejs || return 1
  # local var_pkgfilename="node-v8.1.0-linux-x64.tar.gz"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget https://nodejs.org/dist/v8.1.0/node-v8.1.0-linux-x64.tar.gz -P "${var_pkgdir}/"
  # [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  # sudo tar -zxvf "${var_pkgdir}/${var_pkgfilename}" -C "${var_execdir}" || return 1
  # printf -- "\n" >> "${var_envfile}" || return 1
  # printf -- "\nexport NODEJS_HOME=\"${var_execdir}/node-v8.1.0-linux-x64/bin\"" >> "${var_envfile}" || return 1
  # printf -- '\nexport PATH="$NODEJS_HOME":"$PATH"' >> "${var_envfile}" || return 1
  # printf -- "\n" >> "${var_envfile}" || return 1
}

inst__linux_ubuntu_JDK() {
  inst__linux_ubuntu_check_to_install "$1" "Install JDK[1.8.0_131] (y/n)? " || return 0
  local var_pkgfilename="jdk-8u131-linux-x64.tar.gz"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz -P "${var_pkgdir}/"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  sudo tar -zxvf "${var_pkgdir}/${var_pkgfilename}" -C "${var_execdir}" || return 1
  printf -- "\n" >> "${var_envfile}" || return 1
  printf -- "\nexport JAVA_HOME=\"${var_execdir}/jdk1.8.0_131\"" >> "${var_envfile}" || return 1
  printf -- '\nexport PATH="$JAVA_HOME/bin":"$PATH"' >> "${var_envfile}" || return 1
  printf -- "\n" >> "${var_envfile}" || return 1
}

inst__linux_ubuntu_Maven() {
  inst__linux_ubuntu_check_to_install "$1" "Install Maven[3.5.0] (y/n)? " || return 0
  local var_pkgfilename="apache-maven-3.5.0-bin.tar.gz"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget http://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.0/apache-maven-3.5.0-bin.tar.gz -P "${var_pkgdir}/"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  sudo tar -zxvf "${var_pkgdir}/${var_pkgfilename}" -C "${var_execdir}" || return 1
  printf -- "\n" >> "${var_envfile}" || return 1
  printf -- "\nexport MAVEN_HOME=\"${var_execdir}/apache-maven-3.5.0\"" >> "${var_envfile}" || return 1
  printf -- '\nexport PATH="$MAVEN_HOME/bin":"$PATH"' >> "${var_envfile}" || return 1
  printf -- "\n" >> "${var_envfile}" || return 1
}

inst__linux_ubuntu_IntelliJIDEA() {
  inst__linux_ubuntu_check_to_install "$1" "Install IntelliJIDEA[2018.2.4] (y/n)? " || return 0
  local var_pkgfilename="ideaIC-2018.2.4.tar.gz"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || wget https://download-cf.jetbrains.com/idea/ideaIC-2018.2.4.tar.gz -P "${var_pkgdir}/"
  [ -f "${var_pkgdir}/${var_pkgfilename}" ] || return 1
  sudo tar -zxvf "${var_pkgdir}/${var_pkgfilename}" -C "${var_execdir}" || return 1
  # printf -- "\n" >> "${var_envfile}" || return 1
  # printf -- '\nexport PATH="'"${var_execdir}/idea-IC-182.4505.22/bin"'":"$PATH"' >> "${var_envfile}" || return 1
  # printf -- "\n" >> "${var_envfile}" || return 1
}

inst__linux_ubuntu_WechatWebDevtools() {
  inst__linux_ubuntu_check_to_install "$1" "Install Wechat Web Devtools[latest] (y/n)? " || return 0
  sudo apt-get -y install wine-binfmt || return 1
  sudo update-binfmts --import /usr/share/binfmts/wine || return 1
  git clone https://github.com/cytle/wechat_web_devtools.git ~/Desktop/Repo/wechat_web_devtools || return 1
  ~/Desktop/Repo/wechat_web_devtools/bin/wxdt install || return 1
}

main() {
  while true; do
    # cd $(cd `dirname "$(readlink -- "$0" || printf -- "$0")"` && pwd)
    cd $(cd `dirname $0` && pwd)
    read -p "Do you want to install customized desktop experiences (y/n)? " var_forInstallDesktop
    read -p "Do you want to install predefined essential dev suites (y/n)? " var_forEssential
    read -p "Do you want to install predefined front-end dev suites (y/n)? " var_forFrontEnd
    read -p "Do you want to install predefined back-end dev suites (y/n)? " var_forBackEnd
    local var_pathPkgs=""
    read -p "Enter the directory path where installation packages are stored and to be loaded from (leave empty for default: ${var_pkgdir})? " var_pathPkgs
    [ -z "${var_pathPkgs}" ] || var_pkgdir="${var_pathPkgs}"
    mkdir -p "${var_pkgdir}" || break
    set -x

    # 准备依赖环境
    sudo apt-get -y update
    sudo apt-get -yf install

    ##### 基础依赖 #####

    # 安装 cURL
    inst__linux_ubuntu_with_apt "curl" || break

    # 安装 desktop
    [ "y" = "${var_forInstallDesktop}" ] && {
      inst__linux_ubuntu_with_apt "ubuntu-desktop" || break
      inst__linux_ubuntu_with_apt "xrdp" || break
    }

    ##### 开发依赖 #####

    ## 准备安装各 basic 组件
    # var_pkgdir="${var_pathPkgs}/basic-pkgs"
    # mkdir -p "${var_pkgdir}" || break

    # 安装 VSCode
    inst__linux_ubuntu_VSCode "${var_forEssential}" || break

    # 安装 Chrome
    inst__linux_ubuntu_GoogleChrome "${var_forEssential}" || break

    # 安装 Docker
    inst__linux_ubuntu_Docker "${var_forEssential}" || break
    # sudo reboot

    ## 准备安装各 dev 组件
    # var_pkgdir="${var_pathPkgs}/prj-dev-pkgs"
    # mkdir -p "${var_pkgdir}" || break

    # 安装 NodeJS
    inst__linux_ubuntu_NodeJS "${var_forFrontEnd}" || break

    # # 安装 Wechat Web Devtools
    # inst__linux_ubuntu_WechatWebDevtools "${var_forFrontEnd}" || break

    # 安装 JDK
    inst__linux_ubuntu_JDK "${var_forBackEnd}" || break

    # 安装 Maven
    inst__linux_ubuntu_Maven "${var_forBackEnd}" || break

    # 安装 IntelliJ IDEA
    inst__linux_ubuntu_IntelliJIDEA "${var_forBackEnd}" || break

    # 部分设置在重启后生效
    sudo apt-get -yf install
    set +x
    printf -- "\n[$(date) @ X] Success! Please reboot to finish\n"
    return 0
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"

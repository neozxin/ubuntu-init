#!/bin/sh
## ================ Alpine Linux Init Scripts: 1.0.181229 ================
set -x
var_reposFile="/etc/apk/repositories"
# # Add more apk repositories:
# var_repo1="http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community"
# grep -qx "${var_repo1}" "${var_reposFile}" || echo "${var_repo1}" >> "${var_reposFile}"
# Replace apk repositories:
cp "${var_reposFile}" "${var_reposFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC"
cat > "${var_reposFile}" << XEOFX

#/media/cdrom/apks
http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/main
http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/community
#http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/main
#http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community
#http://mirrors.tuna.tsinghua.edu.cn/alpine/edge/testing

XEOFX

# Update system:
apk update
apk upgrade
#apk add wget # To make sure authentication is supported

# Replace ssh config:
var_sshCfgFile="/etc/ssh/sshd_config"
var_sshPermitRootLogin="PermitRootLogin yes"
cp "${var_sshCfgFile}" "${var_sshCfgFile}_BAK$(date -u +'%Y-%m-%dT%H-%M-%S')UTC"
grep -qx "${var_sshPermitRootLogin}" "${var_sshCfgFile}" || printf -- "\n\n${var_sshPermitRootLogin}\n" >> "${var_sshCfgFile}"

# Add user:
newUSER="zx"
id -u $newUSER &>/dev/null || adduser --disabled-password --gecos "" $newUSER
echo "$newUSER":"$newUSER" | chpasswd
# var_pathMySudoers=~/"mysudoers_$(date +%s%N)"
# printf -- "\n\n$newUSER ALL=(ALL:ALL) NOPASSWD: ALL\n" > "${var_pathMySudoers}" \
#  && chown root:root "${var_pathMySudoers}" \
#  && chmod 0440 "${var_pathMySudoers}" \
#  && rm -rf "/etc/sudoers.d/${var_pathMySudoers}" \
#  && mv "${var_pathMySudoers}" "/etc/sudoers.d/"

# Add Docker: ref: http://janhapke.com/blog/installing-docker-daemon-on-alpine-linux/
apk add docker \
&& rc-update add docker boot \
&& service docker start #\
# && usermod -aG docker $newUSER

# Load any saved Docker images:
for f in dockerimg@*; do cat $f | docker load; done

# # Run container remote desktop: ref: https://vocon-it.com/2016/04/28/running-gui-apps-with-docker-for-remote-access/
# docker run --name "zx-vnc-container" -p 5901:5901 -p 6901:6901 --restart=always -v "/usr/src/0.host-share":"/usr/src/0.host-share" -d "consol/ubuntu-xfce-vnc:1.4.0"

set +x

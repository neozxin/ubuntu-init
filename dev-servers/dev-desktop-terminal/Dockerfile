FROM psharkey/novnc:3.3-t6

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=zh_CN.UTF-8 \
	LANGUAGE=zh_CN.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1024 \
	DISPLAY_HEIGHT=768
ENV DEV_DESKTOP_HOSTNAME="172.17.0.1" \
    DEV_DESKTOP_USERNAME="root"

#### Switch to faster repository mirrors
ARG path_apkrepos="/etc/apk/repositories"
ARG content_apkrepos="${content_apkrepos}\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/v3.3/main"
ARG content_apkrepos="${content_apkrepos}\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/v3.3/community"
RUN cp "${path_apkrepos}" "${path_apkrepos}_BAK" \
    && printf -- "${content_apkrepos}\n" > "${path_apkrepos}"

RUN apk --update add openssh

WORKDIR "$HOME/logs"
WORKDIR "$HOME"

#### Install ttyd
ADD https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 ttyd.x86_64
RUN chmod +x ttyd.x86_64

#### Set up SSH launcher
ARG setsshhost='read -p "Login to host [${DEV_DESKTOP_HOSTNAME}]: " var__sshhost && var__sshhost=${var__sshhost:-${DEV_DESKTOP_HOSTNAME}}'
ARG setsshuser='read -p "Login ${DEV_DESKTOP_HOSTNAME} as user [${DEV_DESKTOP_USERNAME}]: " var__sshuser && var__sshuser=${var__sshuser:-${DEV_DESKTOP_USERNAME}}'
ARG sshcmd='ssh -X "${var__sshuser}@${var__sshhost}"'
RUN filecontent="#!/bin/sh" \
    && filecontent="${filecontent}\n${setsshhost} && ${setsshuser} && ${sshcmd}" \
    && printf -- "${filecontent}\n" > "launch-ssh.sh" \
    && chmod +x "launch-ssh.sh"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900 6080 7681

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

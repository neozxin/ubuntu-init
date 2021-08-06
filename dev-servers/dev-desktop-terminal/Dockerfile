ARG STAGE0="alpine:3.13.5"

# FROM "$STAGE0" as STAGE_BUILDER
FROM "$STAGE0"

ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0

#### Switch to faster repository mirrors
ARG path_apkrepos="/etc/apk/repositories"
RUN cp "${path_apkrepos}" "${path_apkrepos}_BAK" \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' "${path_apkrepos}"

RUN apk --update --upgrade add \
    openssh \
    bash \
    fluxbox \
    socat \
    supervisor \
    x11vnc \
    xterm \
    xvfb

WORKDIR "$HOME/logs"
WORKDIR "$HOME"

#### Install noVNC
ADD https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz noVNC.tar.gz
ADD https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz websockify.tar.gz
RUN tar -xzf ./noVNC.tar.gz \
    && tar -xzf ./websockify.tar.gz \
    && rm -rf ./noVNC.tar.gz ./websockify.tar.gz \
    && mv ./noVNC-1.2.0 ./noVNC \
    && mv ./websockify-0.10.0 ./noVNC/utils/websockify \
    && mv ./noVNC/utils/launch.sh ./noVNC/utils/novnc_proxy \
    && sed -i -- "s/ps -p/ps -o pid | grep/g" ./noVNC/utils/novnc_proxy
# RUN git clone --depth 1 https://github.com/novnc/noVNC.git ./noVNC \
#     && git clone --depth 1 https://github.com/novnc/websockify ./noVNC/utils/websockify \
#     && rm -rf ./noVNC/.git ./noVNC/utils/websockify/.git \
#     && apk del git \
#     && sed -i -- "s/ps -p/ps -o pid | grep/g" ./noVNC/utils/novnc_proxy

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

ENV DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    DEV_DESKTOP_HOSTNAME="172.17.0.1" \
    DEV_DESKTOP_USERNAME="root"

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

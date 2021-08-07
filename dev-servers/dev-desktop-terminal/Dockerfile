ARG STAGE0="alpine:3.14.1"

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
    fluxbox \
    socat \
    runit \
    nginx \
    # busybox-extras \
    # bash \
    # supervisor \
    x11vnc \
    xterm \
    xvfb

WORKDIR "$HOME/logs"
WORKDIR "$HOME"

#### Install noVNC
ADD https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz noVNC.tar.gz
RUN tar -xzf ./noVNC.tar.gz \
    && rm -rf ./noVNC.tar.gz \
    && mv ./noVNC-1.2.0 /var/lib/nginx/html/noVNC
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

#### Set up services
RUN setapp='mkdir -p "/etc/service/${app_key}" && printf -- "#!/bin/sh\n${app_cmd}" > "/etc/service/${app_key}/run" && chmod +x "/etc/service/${app_key}/run"' \
    && env app_key='xvfb' app_cmd='Xvfb :0 -screen 0 "$DISPLAY_WIDTH"x"$DISPLAY_HEIGHT"x24' sh -c "$setapp" \
    && env app_key='x11vnc' app_cmd='x11vnc' sh -c "$setapp" \
    && env app_key='socat' app_cmd='socat tcp-listen:6000,reuseaddr,fork unix:/tmp/.X11-unix/X0' sh -c "$setapp" \
    && env app_key='fluxbox' app_cmd='fluxbox' sh -c "$setapp" \
    && env app_key='shell' app_cmd='xterm -e "$HOME/launch-ssh.sh"' sh -c "$setapp" \
    && env app_key='ttyd' app_cmd='$HOME/ttyd.x86_64 -p 7681 sh -c "$HOME/launch-ssh.sh"' sh -c "$setapp" \
    && env app_key='novnc' app_cmd='nginx -g "daemon off;"' sh -c "$setapp" \
    # && env app_key='novnc' app_cmd='httpd -fv -p 6080 -h $HOME/noVNC' sh -c "$setapp" \
    # && env app_key='novnc' app_cmd='$HOME/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080' sh -c "$setapp" \
    && setapp=''
COPY terminal.default.conf /etc/nginx/http.d/
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900 6080 7681 8080

ENV DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    DEV_DESKTOP_HOSTNAME="172.17.0.1" \
    DEV_DESKTOP_USERNAME="root"

CMD ["runsvdir", "-P", "/etc/service"]
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

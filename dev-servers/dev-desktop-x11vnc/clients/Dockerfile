FROM python:slim

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=zh_CN.UTF-8 \
	LANGUAGE=zh_CN.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1024 \
	DISPLAY_HEIGHT=768

RUN apt-get update && apt-get -y install \
    supervisor \
    procps \
    git

RUN pip3 install webssh

RUN git clone https://github.com/novnc/noVNC.git /root/noVNC \
    && git clone https://github.com/novnc/websockify.git /root/noVNC/utils/websockify \
    && rm -rf /root/noVNC/.git \
    && rm -rf /root/noVNC/utils/websockify/.git \
    && apt-get remove -y git

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 6080 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

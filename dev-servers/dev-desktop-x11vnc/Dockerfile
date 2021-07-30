FROM alpine:latest

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=zh_CN.UTF-8 \
	LANGUAGE=zh_CN.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1024 \
	DISPLAY_HEIGHT=768

RUN apk --update --upgrade add \
	socat \
	supervisor \
	x11vnc \
	xterm \
	xvfb

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM alpine:latest

ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LANG=zh_CN.UTF-8 \
	LANGUAGE=zh_CN.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0.0 \
	DISPLAY_WIDTH=1024 \
	DISPLAY_HEIGHT=768

#### Switch to faster repository mirrors
ARG path_apkrepos="/etc/apk/repositories"
RUN cp "${path_apkrepos}" "${path_apkrepos}_BAK" \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' "${path_apkrepos}"

RUN apk --update --upgrade add \
	socat \
	supervisor \
	x11vnc \
	xterm \
	xvfb

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

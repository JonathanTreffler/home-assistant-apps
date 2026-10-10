FROM ghcr.io/home-assistant/base:latest

RUN apk add --no-cache supercronic

COPY rootfs /

RUN chmod a+x /copy_certs.sh

CMD ["supercronic","-passthrough-logs","/etc/crontab"]

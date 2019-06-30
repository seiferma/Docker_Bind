FROM alpine:latest

WORKDIR /bind

RUN VERSION=9.14.3-r0 && \
    apk --no-cache add bind=${VERSION} bind-tools=${VERSION} && \
    VERSION=

COPY ["start.sh", "addZone.sh", "./"]

ENV CFG_VOLUME=/cfg
RUN mkdir -p ${CFG_VOLUME} && \
    chown named:named ${CFG_VOLUME}

USER named

EXPOSE 5300
EXPOSE 5300/udp

ENTRYPOINT ["./start.sh"]
CMD ["default"]

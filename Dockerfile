FROM dronee/plugin-base

RUN apk add --no-cache openssh-client socat
ARG APP_DIR=/ssh
ENV SSH_AUTH_SOCK=${APP_DIR}/auth.sock
VOLUME ${APP_DIR}
EXPOSE 2000

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]

FROM dronee/plugin-base

RUN apk add --no-cache openssh-client socat
ARG APP_DIR=/ssh
ENV SSH_AUTH_SOCK=${APP_DIR}/auth/sock
RUN mkdir -p $APP_DIR && chmod 777 $APP_DIR
VOLUME ${APP_DIR}

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]

#!/usr/bin/with-contenv sh

export TZ=${TZ:="Europe/Moscow"}
export APP_UID=${APP_UID:=1000}
export APP_GID=${APP_GID:=1000}
export APP_DIR=${APP_DIR:="/app"}
export APP_PUBLIC_DIR=${APP_PUBLIC_DIR:="${APP_DIR}/public"}

echo "export PWD=${APP_DIR}" >> /etc/profile.d/env.sh

if [[ -n "${ENV}" ]]; then
    export APP_ENV=${ENV}
else
    export APP_ENV=${APP_ENV:="production"}
    export ENV=${APP_ENV}
fi

if [[ "${ENV}" = "production" ]]; then
    export IS_PRODUCTION=1
    export IS_NOT_PRODUCTION=0
else
    export IS_PRODUCTION=0
    export IS_NOT_PRODUCTION=1
fi

export DOMAIN=${DOMAIN:=""}
export SERVER_NAME=${DOMAIN:="_"}
export REAL_IP_HEADER=${REAL_IP_HEADER:=1}
export REAL_IP_FROM=${REAL_IP_FROM:=""}
export HIDE_NGINX_HEADERS=${HIDE_NGINX_HEADERS:=$IS_PRODUCTION}
export PHP_ERRORS=${PHP_ERRORS:="$IS_NOT_PRODUCTION"}
export PHP_MEM_LIMIT=${PHP_MEM_LIMIT:="128M"}
export PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:="100M"}
export PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:="100M"}

s6-dumpenv /var/run/s6/container_environment

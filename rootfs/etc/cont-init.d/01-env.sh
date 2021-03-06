#!/usr/bin/with-contenv sh

set -a
ENV_FILE=${ENV_FILE:=/.env}
if [ -r $ENV_FILE ]; then
    . $ENV_FILE
fi


set +a
ENV_DIR=${ENV_DIR:=/var/env}
if [ -d $ENV_DIR ]; then
    for file in $ENV_DIR/* ; do
        if [ -r $file ]; then
            export "$(basename $file)"="$(cat $file)"
        fi
    done
fi


set -a

APP_TZ=${APP_TZ:="Europe/Moscow"}
APP_UID=${APP_UID:=1000}
APP_GID=${APP_GID:=1000}
APP_DIR=${APP_DIR:="/app"}
APP_PUBLIC_DIR=${APP_PUBLIC_DIR:="${APP_DIR}/public"}

PWD=$APP_DIR

if [[ -n "${ENV}" ]]; then
    APP_ENV=${ENV}
else
    APP_ENV=${APP_ENV:="production"}
    ENV=${APP_ENV}
fi

if [[ "${ENV}" = "production" ]]; then
    IS_PRODUCTION=1
    IS_NOT_PRODUCTION=0
else
    IS_PRODUCTION=0
    IS_NOT_PRODUCTION=1
fi

DOMAIN=${DOMAIN:=""}
SERVER_NAME=${DOMAIN:="_"}
REAL_IP_HEADER=${REAL_IP_HEADER:=1}
REAL_IP_FROM=${REAL_IP_FROM:=""}
HIDE_NGINX_HEADERS=${HIDE_NGINX_HEADERS:=$IS_PRODUCTION}
PHP_ERRORS=${PHP_ERRORS:="$IS_NOT_PRODUCTION"}
PHP_MEM_LIMIT=${PHP_MEM_LIMIT:="128M"}
PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:="100M"}
PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:="100M"}

s6-dumpenv /var/run/s6/container_environment

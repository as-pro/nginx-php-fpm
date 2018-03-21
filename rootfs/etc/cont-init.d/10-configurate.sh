#!/usr/bin/with-contenv sh


### user
if [[ $(id -u nginx) != ${APP_UID} || $(id -g nginx) != ${APP_GID} ]]; then
    deluser nginx
    addgroup -g ${APP_GID} nginx
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx -u ${APP_UID} nginx
fi



### dirs
mkdir -p $APP_DIR
mkdir -p $APP_PUBLIC_DIR
chown -Rf nginx:nginx $APP_DIR
chown -Rf nginx:nginx $APP_PUBLIC_DIR



### php vars
cat > /usr/local/etc/php/conf.d/docker-vars.ini <<- PHP_VARS
cgi.fix_pathinfo=0
variables_order = "EGPCS"
memory_limit = $PHP_MEM_LIMIT
post_max_size = $PHP_POST_MAX_SIZE
upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE
date.timezone = $APP_TZ
PHP_VARS



### php fpm conf
PHP_FPM_CONF="/usr/local/etc/php-fpm.d/www.conf"

sed -i \
    -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
    -e "s/pm.max_children = 5/pm.max_children = 4/g" \
    -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
    -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
    -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
    -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
    -e "s/user = www-data/user = nginx/g" \
    -e "s/group = www-data/group = nginx/g" \
    -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
    -e "s/;listen.owner = www-data/listen.owner = nginx/g" \
    -e "s/;listen.group = www-data/listen.group = nginx/g" \
    -e "s/^;clear_env = no$/clear_env = no/" \
    ${PHP_FPM_CONF}

if [[ "$PHP_ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> ${PHP_FPM_CONF}
else
 echo php_flag[display_errors] = on >> ${PHP_FPM_CONF}
fi



### nginx conf
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_SITE_CONF="/etc/nginx/nginx-site.conf"

sed -i \
    -e "s/root /app/public;/root ${APP_PUBLIC_DIR};/" \
    -e "s/server_name _;/server_name ${SERVER_NAME};/" \
    ${NGINX_SITE_CONF}

if [[ "$REAL_IP_HEADER" == "1" ]] ; then
 sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" $NGINX_SITE_CONF
 sed -i "s/#set_real_ip_from/set_real_ip_from/" $NGINX_SITE_CONF
 if [ ! -z "$REAL_IP_FROM" ]; then
  sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" $NGINX_SITE_CONF
 fi
fi



### Display Version Details or not
if [[ "$HIDE_NGINX_HEADERS" == "0" ]] ; then
 sed -i "s/server_tokens off;/server_tokens on;/g" $NGINX_CONF
else
 echo php_flag[expose_php] = off >> ${PHP_FPM_CONF}
fi
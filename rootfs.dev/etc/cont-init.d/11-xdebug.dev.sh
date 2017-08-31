#!/usr/bin/with-contenv sh

XDEBUG_CONFIG_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
XDEBUG_SO=`find  /usr/local/lib/php/extensions/ -name xdebug*`

if [[ ! -f "$XDEBUG_CONFIG_FILE" && -f "$XDEBUG_SO" ]]; then

    echo "Enabling xdebug"

	XDEBUG_IDEKEY=${XDEBUG_IDEKEY:='PHPSTORM'}
	XDEBUG_REMOTE_IP=${XDEBUG_REMOTE_IP:='127.0.0.1'}
	XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:='9000'}
	XDEBUG_REMOTE_ENABLE=${XDEBUG_REMOTE_ENABLE:=1}
	XDEBUG_REMOTE_CONNECT_BACK=${XDEBUG_REMOTE_CONNECT_BACK:=1}

	if [ ! -z "$XDEBUG_SO" ]; then
		cat > $XDEBUG_CONFIG_FILE <<- EOM
		zend_extension=$XDEBUG_SO
		xdebug.remote_autostart=true
		xdebug.remote_mode=req
		xdebug.remote_handler=dbgp
		xdebug.remote_connect_back=$XDEBUG_REMOTE_CONNECT_BACK
		xdebug.remote_port=$XDEBUG_REMOTE_PORT
		xdebug.remote_host=$XDEBUG_REMOTE_IP
		xdebug.idekey=$XDEBUG_IDEKEY
		xdebug.remote_enable=$XDEBUG_REMOTE_ENABLE
		xdebug.profiler_append=0
		xdebug.profiler_enable=0
		xdebug.profiler_enable_trigger=1
		xdebug.profiler_output_dir=/var/debug
		xdebug.profiler_output_name=cachegrind.out.%s.%u
		xdebug.var_display_max_data=-1
		xdebug.var_display_max_children=-1
		xdebug.var_display_max_depth=-1
		EOM
	fi

fi
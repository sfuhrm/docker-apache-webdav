#!/bin/sh

set -eu

MOUNTPOINT="/media/data/"
CONFIG_FILE="/etc/apache2/conf.d/webdav.conf"
CONFIG_TEMPLATE="/etc/apache2/conf.d/webdav.conf.template"
HTPASSWD="/var/lib/apache2/htpasswd"

if [ ! -d "/etc/apache2/conf.d" ]; then
	echo "Could not find conf.d config dir, exiting!"
	exit 1
fi
if [ ! -f "$CONFIG_TEMPLATE" ]; then
	echo "Could not find config template $CONFIG_TEMPLATE, exiting!"
	exit 2
fi
if [ ! -d "$MOUNTPOINT" ]; then
	echo "Could not find data $MOUNTPOINT dir, exiting!"
	exit 3
fi
if [ ! -r "$MOUNTPOINT" ]; then
	echo "Could not read-access data $MOUNTPOINT dir, exiting!"
	exit 4
fi

# Regenerate the config from the immutable template on every start to stay idempotent
cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

HTPASSWD_FILE="${HTPASSWD_FILE:-}"

if [ -n "$HTPASSWD_FILE" ]; then
	if [ -r "$HTPASSWD_FILE" ]; then
		echo "Credentials taken from htpasswd file $HTPASSWD_FILE."
		cp "$HTPASSWD_FILE" "$HTPASSWD"
		chmod 600 "$HTPASSWD"
	else
		echo "Htpasswd file $HTPASSWD_FILE is not readable!"
		exit 5
	fi
else
	echo "Using no auth."
	sed -i -e '/AuthType/d' -e '/AuthName/d' -e '/AuthBasicProvider/d' -e '/AuthUserFile/d' \
	       -e 's/Require valid-user/Require all granted/' "$CONFIG_FILE"
fi

# Validate the generated config before starting httpd
httpd -t

exec "$@"

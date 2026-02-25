#!/bin/sh
sed -e "s|\${DOMAIN}|${DOMAIN}|g" -e "s|\${TZ}|${TZ}|g" /srv/config/goaccess.conf.template > /srv/config/goaccess.conf
exec /usr/bin/goaccess --no-global-config --config-file=/srv/config/goaccess.conf

#!/usr/bin/env bash

set -eu -o pipefail
shopt -s extglob

# Uninstall and clean up script

# /srv/timeline/
SRVDIR=$1

# /etc/nginx/
NGINXDIR=$2

# /etc/systemd/system/
SYSTEMDDIR=$3

# /var/lib/timeline/sqlite3/
DATABASEDIR=$4

rm -rf ${SRVDIR}root/!(.well-known|.|..)

rm -rf "${SRVDIR}frozen/"

rm -f "${NGINXDIR}sites-enabled/timeline.${ENVIRONMENT}.conf";
rm -f "${NGINXDIR}sites-available/timeline.${ENVIRONMENT}.conf";

rm -f "${SRVDIR}.htpasswd";

systemctl stop timeline-chill
systemctl disable timeline-chill
rm -f "${SYSTEMDDIR}timeline-chill.service";

# TODO: Should it remove the database file in an uninstall?
echo "Skipping removal of sqlite database file ${DATABASEDIR}db"
#rm -f "${DATABASEDIR}db"

exit

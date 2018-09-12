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

rm -f /etc/cron.d/awstats-timeline-crontab
# Stop and start in order for the crontab to be loaded (reload not supported).
systemctl stop cron && systemctl start cron || echo "Can't reload cron service"

rm -f /etc/awstats/awstats.timeline.weboftomorrow.com.conf

systemctl stop timeline-chill
systemctl disable timeline-chill
rm -f "${SYSTEMDDIR}timeline-chill.service";

systemctl stop timeline-api
systemctl disable timeline-api
rm -f "${SYSTEMDDIR}timeline-api.service";

# TODO: Should it remove the database file in an uninstall?
echo "Skipping removal of sqlite database file ${DATABASEDIR}db"
#rm -f "${DATABASEDIR}db"

exit

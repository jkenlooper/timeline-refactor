#!/usr/bin/env bash
set -eu -o pipefail

# /srv/timeline/
SRVDIR=$1

# /etc/nginx/
NGINXDIR=$2

# /var/log/nginx/timeline/
NGINXLOGDIR=$3

# /etc/systemd/system/
SYSTEMDDIR=$4

# /var/lib/timeline/sqlite3/
DATABASEDIR=$5

mkdir -p "${SRVDIR}root/";
#chown -R dev:dev "${SRVDIR}root/";
rsync --archive \
  --inplace \
  --delete \
  --exclude=.well-known \
  --itemize-changes \
  root/ "${SRVDIR}root/";
echo "rsynced files in root/ to ${SRVDIR}root/";

mkdir -p "${SRVDIR}dist/timeline/";
rsync --archive \
  --inplace \
  --delete \
  --itemize-changes \
  dist/timeline/ "${SRVDIR}dist/timeline/";
echo "rsynced files in dist/timeline/ to ${SRVDIR}dist/timeline/";

mkdir -p "${NGINXLOGDIR}";

# Run rsync checksum on nginx default.conf since other sites might also update
# this file.
mkdir -p "${NGINXDIR}sites-available"
rsync --inplace \
  --checksum \
  --itemize-changes \
  web/default.conf web/timeline.conf "${NGINXDIR}sites-available/";
echo rsynced web/default.conf web/timeline.conf to "${NGINXDIR}sites-available/";

mkdir -p "${NGINXDIR}sites-enabled";
ln -sf "${NGINXDIR}sites-available/default.conf" "${NGINXDIR}sites-enabled/default.conf";
ln -sf "${NGINXDIR}sites-available/timeline.conf"  "${NGINXDIR}sites-enabled/timeline.conf";

rsync --inplace \
  --checksum \
  --itemize-changes \
  .htpasswd "${SRVDIR}";

if (test -f web/dhparam.pem); then
mkdir -p "${NGINXDIR}ssl/"
rsync --inplace \
  --checksum \
  --itemize-changes \
  web/dhparam.pem "${NGINXDIR}ssl/dhparam.pem";
fi

# Create the sqlite database file if not there.
if (test ! -f "${DATABASEDIR}db"); then
    echo "Creating database from db.dump.sql"
    mkdir -p "${DATABASEDIR}"
    chown -R dev:dev "${DATABASEDIR}"
    su dev -c "sqlite3 \"${DATABASEDIR}db\" < db.dump.sql"
    chmod -R 770 "${DATABASEDIR}"
fi

mkdir -p "${SYSTEMDDIR}"
cp chill/timeline-chill.service "${SYSTEMDDIR}"
systemctl start timeline-chill || echo "can't start service"
systemctl enable timeline-chill || echo "can't enable service"

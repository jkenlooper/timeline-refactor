#!/usr/bin/env bash

set -eu -o pipefail

ENVIRONMENT=$1
SRVDIR=$2
NGINXLOGDIR=$3
PORTREGISTRY=$4

# shellcheck source=/dev/null
source "$PORTREGISTRY"

cat <<HERE

server {
  listen 80;

  root ${SRVDIR}root;

  access_log  ${NGINXLOGDIR}access.log;
  error_log   ${NGINXLOGDIR}error.log;

  error_page 404 /notfound/;

  location = /humans.txt {}
  location = /robots.txt {}
  location = /favicon.ico {}

  location /api/ {

    # Simple requests
    if (\$request_method ~* "(GET|POST)") {
      add_header "Access-Control-Allow-Origin"  *;
    }

    # Preflighted requests
    if (\$request_method = OPTIONS ) {
      add_header "Access-Control-Allow-Origin"  *;
      add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD";
      add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept";
      return 200;
    }

    proxy_pass_header Server;
    proxy_set_header Host \$http_host;
    proxy_set_header  X-Real-IP  \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

    proxy_redirect off;
    proxy_intercept_errors on;
    proxy_pass http://localhost:${PORTCHILL};
    rewrite ^/api/(.*)\$  /\$1 break;
  }

  location / {
    root ${SRVDIR}frozen;
  }

HERE

if test $ENVIRONMENT == 'development'; then

cat <<HEREBEDEVELOPMENT

  server_name local-timeline;

HEREBEDEVELOPMENT

else

cat <<HEREBEPRODUCTION

  server_name timeline.weboftomorrow.com;

HEREBEPRODUCTION
fi

cat <<HERE
}
HERE

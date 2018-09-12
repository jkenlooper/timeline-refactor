#!/usr/bin/env bash

SRCDIR=$1

DATE=$(date)

cat <<HERE

# File generated from $0
# on ${DATE}

[Unit]
Description=Chill timeline instance
After=network.target

[Service]
User=dev
Group=dev
WorkingDirectory=$SRCDIR
ExecStart=${SRCDIR}bin/chill run

[Install]
WantedBy=multi-user.target

HERE

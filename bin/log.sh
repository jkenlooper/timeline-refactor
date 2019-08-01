#!/usr/bin/env bash
set -eu -o pipefail

journalctl --follow \
  _SYSTEMD_UNIT=timeline-chill.service


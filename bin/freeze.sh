#!/usr/bin/env bash
set -eu -o pipefail

FROZEN_TAR=$1

npm run build;

tar --create --auto-compress --file "${FROZEN_TAR}" dist/timeline/

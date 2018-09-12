#!/usr/bin/env bash
set -eu -o pipefail

# Create a distribution for uploading to a production server.

ARCHIVE=$1

# Create symlinks for all files in the MANIFEST.
for item in $(cat timeline/MANIFEST); do
  ln -sf "${PWD}/${item}" timeline/;
  dirname "timeline/${item}" | xargs mkdir -p;
  dirname "timeline/${item}" | xargs ln -sf "${PWD}/${item}";
done;

tar --dereference \
  --exclude=MANIFEST \
  --create \
  --auto-compress \
  --file "${ARCHIVE}" timeline;


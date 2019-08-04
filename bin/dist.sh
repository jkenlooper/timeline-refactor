#!/usr/bin/env bash
set -eu -o pipefail

# Create a distribution for uploading to a production server.

# archive file path should be absolute
ARCHIVE=$1

TMPDIR=$(mktemp --directory);

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

git clone . "$TMPDIR";

(
cd "$TMPDIR";

# Use the node and npm that is set in .nvmrc
nvm use;

# Build
npm ci; # clean install
npm run build;

# Create symlinks for all files in the MANIFEST.
for item in $(cat timeline/MANIFEST); do
  dirname "timeline/${item}" | xargs mkdir -p;
  dirname "timeline/${item}" | xargs ln -sf "${PWD}/${item}";
done;

tar --dereference \
  --exclude=MANIFEST \
  --create \
  --auto-compress \
  --file "${ARCHIVE}" timeline;
)

# Clean up
rm -rf "${TMPDIR}";

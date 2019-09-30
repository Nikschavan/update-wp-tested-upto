#!/bin/bash

# Note that this does not use pipefail because if the grep later
# doesn't match I want to be able to show an error first
set -eo

API_URL=https://api.wordpress.org/core/version-check/1.7/
LATEST_WP=$(curl $API_URL | jq ".offers[0].version")

echo $LATEST_WP

sh -c "git checkout -b 'update-tested-upto-$LATEST_WP' \
      && git add -A && git commit -m 'Updated WordPress tested upto to latest WP version by bsf-bot' --allow-empty \
      && git push -u origin update-tested-upto-$LATEST_WP"
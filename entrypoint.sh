#!/bin/bash

# Note that this does not use pipefail because if the grep later
# doesn't match I want to be able to show an error first
set -eo

API_URL=https://api.wordpress.org/core/version-check/1.7/
LATEST_WP=$(curl $API_URL | jq .offers[0].version | sed 's/"//g')

echo $LATEST_WP

cd $GITHUB_WORKSPACE

git config --global user.email 'update-tested-upto-wp@bsf.io'
git config --global user.name 'Update Tested upto Bot on GitHub'

echo $LATEST_WP
STABLE_TAG=$(grep -m 1 "^Tested up to:" "$GITHUB_WORKSPACE/readme.txt" | tr -d '\r\n' | awk -F ' ' '{print $NF}')
echo $STABLE_TAG

git checkout -b "update-tested-upto-$LATEST_WP"

sed -i "s/Tested up to: $STABLE_TAG/$LATEST_WP/" "$GITHUB_WORKSPACE"/readme.txt

sh -c "git add -A && git commit -m 'Updated WordPress tested upto to latest WP version by bsf-bot' --allow-empty \
      && git push -u origin update-tested-upto-$LATEST_WP"
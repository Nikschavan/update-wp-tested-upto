#!/bin/bash

# Note that this does not use pipefail because if the grep later
# doesn't match I want to be able to show an error first
set -eo

API_URL=https://api.wordpress.org/core/version-check/1.7/
LATEST_WP=$(curl $API_URL | jq ".offers[0].version")

echo $LATEST_WP
STABLE_TAG=$(grep -m 1 "^Tested up to:" "$GITHUB_WORKSPACE/readme.txt" | tr -d '\r\n' | awk -F ' ' '{print $NF}')
echo $STABLE_TAG
sed -i "s/Tested up to: $STABLE_TAG/$LATEST_WP/" "$GITHUB_WORKSPACE"/readme.txt
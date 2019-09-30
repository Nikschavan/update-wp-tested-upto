#!/bin/bash
set -e

API_URL=https://api.wordpress.org/core/version-check/1.7/
LATEST_WP=$(curl $API_URL | jq .offers[0].version | sed 's/"//g')

cd $GITHUB_WORKSPACE

git config --global user.name ${GITHUB_ACTOR}
git config --global user.email ${GITHUB_ACTOR}@users.noreply.github.com

echo $LATEST_WP
STABLE_TAG=$(grep -m 1 "^Tested up to:" "$GITHUB_WORKSPACE/readme.txt" | tr -d '\r\n' | awk -F ' ' '{print $NF}')
echo $STABLE_TAG

DESTINATION_BRANCH="update-tested-upto-$LATEST_WP"
SOURCE_BRANCH='master';

git checkout -b $DESTINATION_BRANCH

sed -i "s/Tested up to: $STABLE_TAG/Tested up to: $LATEST_WP/" "$GITHUB_WORKSPACE"/readme.txt

git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"

# git add -A && git commit -m 'Updated WordPress tested upto to latest WP version by bsf-bot' --allow-empty
# git push -u origin $DESTINATION_BRANCH

export GITHUB_USER=$GITHUB_ACTOR

INPUT_PR_TITLE="Update WP Tested up to to Version $LATEST_WP"
INPUT_PR_BODY="Update Tested up to"

PR_ARG="$INPUT_PR_TITLE"
if [[ ! -z "$PR_ARG" ]]; then
  PR_ARG="-m \"$PR_ARG\""

  if [[ ! -z "$INPUT_PR_BODY" ]]; then
    PR_ARG="$PR_ARG -m \"$INPUT_PR_BODY\""
  fi
fi

COMMAND="hub pull-request \
  -b $DESTINATION_BRANCH \
  -h $SOURCE_BRANCH \
  -p \
  --no-edit \
  $PR_ARG \
  || true"

echo "$COMMAND"
sh -c "$COMMAND"
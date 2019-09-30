#!/bin/bash
set -eo

API_URL=https://api.wordpress.org/core/version-check/1.7/
LATEST_WP=$(curl $API_URL | jq .offers[0].version | sed 's/"//g')

API_VERSION=v3
BASE=https://api.github.com
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
HEADER="Accept: application/vnd.github.$API_VERSION+json"
HEADER="$HEADER; application/vnd.github.antiope-preview+json; application/vnd.github.shadow-cat-preview+json"

# URLs
REPO_URL="$BASE/repos/$GITHUB_REPOSITORY"
PULLS_URL=$REPO_URL/pulls

cd $GITHUB_WORKSPACE

git config --global user.name $GITHUB_ACTOR
git config --global user.email $GITHUB_ACTOR@users.noreply.github.com

echo $LATEST_WP
STABLE_TAG=$(grep -m 1 "^Tested up to:" "$GITHUB_WORKSPACE/readme.txt" | tr -d '\r\n' | awk -F ' ' '{print $NF}')
echo $STABLE_TAG

DESTINATION_BRANCH="update-tested-upto-$LATEST_WP"
SOURCE='master';

git checkout -b $DESTINATION_BRANCH

sed -i "s/Tested up to: $STABLE_TAG/Tested up to: $LATEST_WP/" "$GITHUB_WORKSPACE"/readme.txt

git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"

git add -A && git commit -m 'Updated WordPress tested upto to latest WP version by bsf-bot' --allow-empty
git push -u origin $DESTINATION_BRANCH

DRAFT=false
TITLE="Update Tested up to to $LATEST_WP"
BODY="Testing"


# Check if the branch already has a pull request open

DATA="{\"base\":$DESTINATION_BRANCH, \"head\":$SOURCE, \"body\":$BODY}"
RESPONSE=$(curl -sSL -H "$AUTH_HEADER" -H "$HEADER" --user "$GITHUB_ACTOR" -X GET --data "$DATA" $PULLS_URL)
PR=$(echo "$RESPONSE" | jq --raw-output '.[] | .head.ref')
echo "Response ref: $PR"

# Option 1: The pull request is already open
if [[ "$PR" == "$SOURCE" ]]; then
    echo "Pull request from $SOURCE to $DESTINATION_BRANCH is already open!"

# Option 2: Open a new pull request
else
    # Post the pull request
    DATA="{\"title\":$TITLE, \"body\":$BODY, \"base\":$DESTINATION_BRANCH, \"head\":$SOURCE, \"draft\":$DRAFT}"
    echo "curl --user $GITHUB_ACTOR -X POST --data $DATA $PULLS_URL"
    curl -sSL -H "$AUTH_HEADER" -H "$HEADER" --user "$GITHUB_ACTOR" -X POST --data "$DATA" $PULLS_URL
    echo $?
fi
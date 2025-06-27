#!/bin/sh

set -e

SOURCE_REPO=$1
DESTINATION_REPO=$2
SOURCE_DIR=$(basename "$SOURCE_REPO")
BRANCHES=$3
GIT_SSH_COMMAND="ssh -v"

echo "SOURCE=$SOURCE_REPO"
echo "DESTINATION=$DESTINATION_REPO"
echo "BRANCHES=$BRANCHES"

if [ -z "$BRANCHES" ]; then
    echo "No branches specified in BRANCHES."
    exit 1
fi

git clone "$SOURCE_REPO" "$SOURCE_DIR" && cd "$SOURCE_DIR"
git remote set-url --push origin "$DESTINATION_REPO"

OLD_IFS="$IFS"
IFS=','
set -- $BRANCHES
for BR; do
    echo "Pushing branch: $BR"
    if ! git switch "$BR"; then
        echo "Failed to switch to $BR."
        exit 1
    fi

    if ! git push --no-verify --force; then
        echo "Failed to push branch: $BR"
        exit 1
    fi
done
IFS="$OLD_IFS"

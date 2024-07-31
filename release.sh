#!/bin/sh

[[ git diff --name-only | wc -l -gt 0 ]] && echo "There are uncommitted changes. Please commit or stash them before releasing." && exit 1

VERSION=${cat VERSION}
BRANCH=${git branch --show-current}
RBRANCH="release-v$VERSION"
echo "Releasing version $VERSION from branch $BRANCH into branch $RBRANCH..."

git checkout -b $RBRANCH
touch VERSION_SUFFIX

git commit -a -m "Release version $VERSION"
git tag -a v$VERSION -m "Version $VERSION"
git push --tags

git checkout $BRANCH
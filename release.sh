#!/bin/sh

[[ git diff --name-only | wc -l -gt 0 ]] && echo "There are uncommitted changes. Please commit or stash them before releasing." && exit 1

VERSION=${cat VERSION}
BRANCH=${git branch --show-current}
echo "Releasing version $VERSION from branch $BRANCH..."

git checkout -b release-v$VERSION
touch VERSION_SUFFIX
git commit -a -m "Release version $VERSION"
git tag -a v$VERSION -m "Version $VERSION"
git push --tags

git checkout $BRANCH
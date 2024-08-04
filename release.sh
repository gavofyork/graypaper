#!/bin/bash

[ `git diff --name-only | wc -l` -gt 0 ] && echo "There are uncommitted changes. Please commit or stash them before releasing." && exit 1

VERSION=`cat VERSION`
OBRANCH=`git branch --show-current`
RBRANCH="release-v$VERSION"
echo "Releasing version $VERSION from branch $OBRANCH into branch $RBRANCH..."

git checkout -b $RBRANCH
echo -n '' > context.tex

echo "Committing..."
git commit -a -m "Release version $VERSION"

echo "Building PDF..."
cp graypaper.tex graypaper-$VERSION.tex
function cleanup() {
    rm graypaper-$VERSION.aux graypaper-$VERSION.bbl graypaper-$VERSION.blg graypaper-$VERSION.log graypaper-$VERSION.out graypaper-$VERSION.tex* graypaper-$VERSION.run.xml graypaper-$VERSION.bcf
    git checkout $OBRANCH
}
xelatex -halt-on-error graypaper-$VERSION > /dev/null || ( echo "Cannot build tex. Please fix before releasing." && cleanup && exit 1 )
biber graypaper-$VERSION > /dev/null || ( echo "Cannot build bib. Please fix before releasing." && cleanup && exit 1 )
xelatex -halt-on-error graypaper-$VERSION > /dev/null
xelatex -halt-on-error graypaper-$VERSION > /dev/null

echo "Tagging && pushing..."
git tag -a v$VERSION -m "Version $VERSION"
git push --tags

cleanup

#!/bin/bash

file=$1

git checkout gh-pages
cp $file .
git add $file
if [ $? -eq 0 ]; then
    git commit -m "Update index.html"
    git push
fi
git checkout master

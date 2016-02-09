#!/bin/bash

file=$0

git checkout gh-pages
cp $file .
git status | grep $file 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo "[INFO] Commiting and publishing to GitHub"
    # git add $file
    # git commit -m "Update index.html"
    # git push
else
    echo "[INFO] No changes detected, not publishing"
fi
git checkout master

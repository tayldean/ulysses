#!/bin/bash -x

file=$1
file_basename=`basename $file`

git checkout gh-pages
cp $file .
git status | grep $file_basename 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo "[INFO] Commiting and publishing to GitHub"
    git add $file_basename
    git commit -m "Update index.html"
    git push origin gh-pages
else
    echo "[INFO] No changes detected, not publishing"
fi
git checkout master

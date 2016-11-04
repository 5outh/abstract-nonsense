#! /bin/zsh

site build
cp -r _site/* ../5outh.github.io
cd ../5outh.github.io
echo "Edits include:"
git status
git add . -A
git status
git commit -m "Automated publish"
git push origin master

#!/bin/bash

#TODO: put code for downloading gh cli and setting up github token
if [ -d commit_jars_old ]; then
  rm -r commit_jars_old
fi
#if [ -d commit_jars_new ]; then
#  rm -r commit_jars_new
#fi
mkdir commit_jars_old
#mkdir commit_jars_new

gh repo set-default apache/pinot
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
prnums="$(gh pr list --state merged --json number,mergedAt | jq 'sort_by(.mergedAt) | reverse')"
latest=15938
#$(echo "$prnums" | jq '.[0].number')
#gh pr checkout "$latest"
#mvn clean install -DskipTests
#paths="$(find . -type f -name "*${version}.jar" | tr "\n" " ")"
#IFS=' ' read -r -a namelist <<< "$paths"
#for name in "${namelist[@]}"; do
#  mv "$name" commit_jars_new
#done

sndlatest=6950c85
#$(echo "$prnums" | jq '.[1].number')
git checkout "$sndlatest"
mvn clean install -DskipTests
paths2="$(find . -path ./commit_jars_new -prune -o -name "*${version}.jar" -type f -print | tr "\n" " ")"
IFS=' ' read -r -a namelist2 <<< "$paths2"
for name in "${namelist2[@]}"; do
  mv "$name" commit_jars_old
done

#TODO: change the below to just checking out the gh-pages branch
gh repo set-default matvj250/pinot
git checkout commit-report/japicmp_test

if [ ! -e japicmp.jar ]; then
  JAPICMP_VER=0.23.1
  curl -fSL \
  -o japicmp.jar \
  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
  if [ ! -f japicmp.jar ]; then
    echo "Error: Failed to download japicmp.jar."
    exit 1
  fi
fi

if [ -e japicmp_test.txt ]; then
  echo "" > japicmp_test.txt # erase what's in the text already
else
  touch japicmp_test.txt
fi
for filename in commit_jars_new/*; do
  name="$(basename "$filename")"
  if [ ! -f commit_jars_old/"$name" ]; then
    echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> japicmp_test.txt
    echo "" >> japicmp_test.txt
    continue
  fi
  OLD=commit_jars_old/"$name"
  NEW=commit_jars_new/"$name"
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    -a private \
    --no-annotations \
    --ignore-missing-classes \
    --only-modified >> japicmp_test.txt
done
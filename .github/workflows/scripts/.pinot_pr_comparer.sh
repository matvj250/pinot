#!/bin/bash

#TODO: put code for downloading gh cli and setting up github token

# empty the directories that are meant for holding jars
if [ -d commit_jars_old ]; then
  rm -r commit_jars_old
fi
if [ -d commit_jars_new ]; then
  rm -r commit_jars_new
fi
mkdir commit_jars_old
mkdir commit_jars_new

# move to apache/pinot repo
gh repo set-default apache/pinot
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
# get list of PRs. Right now it's sorted by merge time, but this may change
commits="$(gh search commits repo:apache/pinot --committer-date=">1970-01-01" --sort committer-date --order desc --limit 2 --json sha)"
latest="$(echo "$commits" | jq '.[0].sha' | tr -d '"')" # latest commit hash
sndlatest="$(echo "$commits" | jq '.[1].sha' | tr -d '"')"
latest_pr="$(gh api repos/apache/pinot/commits/"${latest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')" # corresponding PR number
sndlatest_pr="$(gh api repos/apache/pinot/commits/"${sndlatest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')"

gh pr checkout "$latest_pr"
mvn clean install -DskipTests
# get the names of all the jars that just got made
paths="$(find . -type f -name "*${version}.jar" | tr "\n" " ")"
IFS=' ' read -r -a namelist <<< "$paths"
# move them all to the directory for the new jars
for name in "${namelist[@]}"; do
  mv "$name" commit_jars_new
done

# do the same thing, but with the second latest PR and the directory for the old jars
gh pr checkout "$sndlatest_pr"
mvn clean install -DskipTests
paths2="$(find . -path ./commit_jars_new -prune -o -name "*${version}.jar" -type f -print | tr "\n" " ")"
IFS=' ' read -r -a namelist2 <<< "$paths2"
for name in "${namelist2[@]}"; do
  mv "$name" commit_jars_old
done

# move back to my repo and branch
gh repo set-default matvj250/pinot
git checkout commit-report/japicmp_test

# download japicmp.jar, if it isn't already downloaded
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

if [ -e japicmp_test_pr.txt ]; then
  echo "" > japicmp_test_pr.txt # erase what's in the text already
else
  touch japicmp_test_pr.txt
fi

# put japicmp output into a text file
for filename in commit_jars_new/*; do
  name="$(basename "$filename")"
  if [ ! -f commit_jars_old/"$name" ]; then
    echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> japicmp_test.txt
    echo "" >> japicmp_test_pr.txt
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
    --only-modified >> japicmp_test_pr.txt
done
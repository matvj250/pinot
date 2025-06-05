#!/bin/bash

# up here, put code for downloading gh cli,
# setting up github token
# and move set-default
if [ -d commit_jars_old ]; then
  rm -r commit_jars_old
fi
if [ -d commit_jars_new ]; then
  rm -r commit_jars_new
fi
mkdir commit_jars_old
mkdir commit_jars_new

#second and third latest for now, because at the time of making this
#the latest change was dependabot
gh repo set-default apache/pinot
prnums="$(gh pr list --state merged --json number,mergedAt | jq 'sort_by(.mergedAt) | reverse')"
latest=$(echo "$prnums" | jq '.[0].number')
gh pr checkout "$latest"

version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" #there's a % at the end for some reason
modnames="$(mvn -pl :pinot help:effective-pom -amd | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
modnames=${modnames//"module"} # removes the word 'module' from the output
IFS=' ' read -r -a namelist <<< "$modnames"

mvn clean install -DskipTests
for name in "${namelist[@]}"; do # eventually remove temp and switch to namelist directly
  if [ -f "$name"/target/"$name"-"$version".jar ]; then
    mv "$name"/target/"$name"-"$version".jar commit_jars_new
  fi
done

sndlatest=$(echo "$prnums" | jq '.[1].number')
gh pr checkout "$sndlatest"
mvn clean install -DskipTests
for name in "${namelist[@]}"; do # eventually remove temp and switch to namelist directly
  if [ -f "$name"/target/"$name"-"$version".jar ]; then
      mv "$name"/target/"$name"-"$version".jar commit_jars_old
    fi
done

#eventually change the below to just checking out the gh-pages branch
gh repo set-default matvj250/pinot
git checkout commit-report/japicmp_test

if [ ! -f japicmp.jar ]; then
  JAPICMP_VER=0.23.1
  curl -fSL \
  -o japicmp.jar \
  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
  #ensure download was successful
  if [ ! -f japicmp.jar ]; then
    echo "Error: Failed to download japicmp.jar."
    exit 1
  fi
fi

if [ -e japicmp_test.txt ]; then
  echo "" > japicmp_test.txt #erase what's in the text already
else
  touch japicmp_test.txt
fi
for filename in commit_jars_new/*; do
  if [ ! -e commit_jars_old/"$filename" ]; then
    echo "It seems ${name} does not exist in the previous pull request. Please make sure this is intended." >> japicmp_test.txt
    echo "" >> japicmp_test.txt
    continue
  fi
  OLD=commit_jars_old/"$filename"
  NEW=commit_jars_new/"$filename"
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    --no-annotations \
    --ignore-missing-classes \
    --only-modified >> japicmp_test.txt
done
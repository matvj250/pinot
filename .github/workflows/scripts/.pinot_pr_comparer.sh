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

version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" #there's a % at the end for some reason
modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
modnames=${modnames//"module"} # removes the word 'module' from the output
IFS=' ' read -r -a namelist <<< "$modnames"

#second and third latest for now, because at the time of making this
#the latest change was dependabot
gh repo set-default apache/pinot
latest=15685
#"$(gh pr list --state merged --json number,mergedAt --limit 50 | jq 'sort_by(.mergedAt) | reverse | .[0].number')"
gh pr checkout "$latest"
for name in "${namelist[@]}"; do # eventually remove temp and switch to namelist directly
  mvn clean install -pl "$name" -DskipTests
  mv "$name"/target/"$name"-"$version".jar commit_jars_new
done

sndlatest=15203
#"$(gh pr list --state merged --json number,mergedAt --limit 50 | jq 'sort_by(.mergedAt) | reverse | .[1].number')"
gh pr checkout "$sndlatest"
for name in "${namelist[@]}"; do # eventually remove temp and switch to namelist directly
  mvn clean install -pl "$name" -DskipTests
  mv "$name"/target/"$name"-"$version".jar commit_jars_old
done

#eventually change the below to just checking out the gh-pages branch
gh repo set-default matvj250/pinot
git checkout commit-report/japicmp_test

if [ ! -d japicmp.jar ]; then
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
for name in "${namelist[@]}"; do
  if [ ! -e commit_jars_old/"$name"-"$version".jar ] || [ ! -e commit_jars_new/"$name"-"$version".jar ]; then
    echo "It seems ${namelist[num]} does not exist in one or both of the pull requests. Please look into this." >> japicmp.txt
    continue
  fi
  OLD=commit_jars_old/"${name}"-"$version".jar
  NEW=commit_jars_new/"${name}"-"$version".jar
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    --no-annotations \
    --ignore-missing-classes \
    --only-modified >> japicmp_test.txt
done
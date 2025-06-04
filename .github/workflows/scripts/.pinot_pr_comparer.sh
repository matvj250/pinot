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
temp=(0 1)
for num in "${temp[@]}"; do # eventually remove temp and switch to namelist directly
  mvn clean install -pl "${namelist[num]}" -DskipTests
  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_new
done

sndlatest=15203
#"$(gh pr list --state merged --json number,mergedAt --limit 50 | jq 'sort_by(.mergedAt) | reverse | .[1].number')"
gh pr checkout "$sndlatest"
for num in "${temp[@]}"; do # eventually remove temp and switch to namelist directly
  mvn clean install -pl "${namelist[num]}" -DskipTests
  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_old
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

#touch japicmp_test.txt
for num in "${temp[@]}"; do
  if [ ! -e commit_jars_old/"${namelist[num]}"-"$version".jar ] || [ ! -e commit_jars_new/"${namelist[num]}"-"$version".jar ]; then
    echo "Discrepancy between pull requests relating to existence of ${namelist[num]}. This should be investigated."
    continue
  fi
  ${namelist[num]} >> japicmp_test.txt
  OLD=commit_jars_old/"${namelist[num]}"-"$version".jar
  NEW=commit_jars_new/"${namelist[num]}"-"$version".jar
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    --no-annotations \
    --ignore-missing-classes \
    --only-modified >> japicmp_test.txt
done
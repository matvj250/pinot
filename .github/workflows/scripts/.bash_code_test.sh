#!/bin/bash

gh repo set-default apache/pinot
prnums="$(gh search commits repo:apache/pinot --committer-date=">1970-01-01" --sort committer-date --order desc --limit 2 --json sha)"
latest=$(echo "$prnums" | jq '.[0].sha' | tr -d '"') # latest PR
sndlatest=$(echo "$prnums" | jq '.[1].sha' | tr -d '"')
gh api repos/apache/pinot/commits/"${latest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number'
#prnums="$(gh pr list --state merged --json number,mergedAt,mergeCommit | jq 'sort_by(.mergedAt) | reverse')"
#latest=$(echo "$prnums" | jq '.[0]')
#latest_hash=$(echo "$latest" | jq '.mergeCommit.oid')
#latest_num=$(echo "$latest" | jq '.number')
##latest=$(jq '[.[] | .mergeCommit = .mergeCommit[0].oid' <<< "$latest")
#echo "$latest_hash"
#echo "$latest_num"
#prnums="$(jq '[.[] | .mergeCommit = .mergeCommit.oid | del(.mergeCommit) + {mergeCommit: .mergeCommit}]' "$prnums")"

#version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
#find . -path ./commit_jars_new -prune -o -name "*${version}.jar" -type f -print #| tr "\n" " "

#IFS=' ' read -r -a namelist2 <<< "$paths2"
#for name in "${namelist2[@]}"; do
#  mv "$name" commit_jars_old
#done

#modnames="$(mvn -pl :pinot help:effective-pom -amd | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
#modnames=${modnames//"module"} # removes the word 'module' from the output
#IFS=' ' read -r -a namelist <<< "$modnames"
#echo "${namelist[@]}"

#for filename in commit_jars_new/*; do
#  temp="$(basename "$filename")"
#    if [ ! -f commit_jars_old/"$temp" ]; then
#    echo "It seems $temp does not exist in the previous pull request. Please make sure this is intended."
#    continue
#  else
#    echo "wfiqwjgoiwegoiwenbvoihjvownboew"
#  fi
#done

#echo "hello 1"
#if [ ! -f japicmp.jar ]; then
#  JAPICMP_VER=0.23.1
#  curl -fSL \
#  -o japicmp.jar \
#  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
#  echo "hello 2"
#  #ensure download was successful
#  if [ ! -f japicmp.jar ]; then
#    echo "Error: Failed to download japicmp.jar."
#    exit 1
#  fi
#fi

## theoretically, we'd need to make code for checking out the alternate branch
## but that isn't relevant right now, and this test code is in
## an alternate branch already
#if [ -d commit_jars_frst ]; then
#  rm -r commit_jars_frst
#fi
#if [ -d commit_jars_scnd ]; then
#  rm -r commit_jars_scnd
#fi
#mkdir commit_jars_frst
#mkdir commit_jars_scnd
#version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" #there's a % at the end for some reason
#modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
#modnames=${modnames//"module"} # removes the word 'module' from the output
#IFS=' ' read -r -a namelist <<< "$modnames"
##for item in "${namelist[@]}"; do
##  echo "$item"
##done
#
## use github cli to get pr-level operations(?)
## pr-level and commit level is different
#
## originally did 608f891 vs c7ce654 for common and controller (4 8)
## but there was some error with compiling controller that showed up in master too
## so pivoting to my broker-server commit
## same error with broker and server. I think something needs to be compiled
## before everything else.
#git checkout db2f78c
##mvn clean package -pl $ -DskipTests
#temp=(0 1 2 4 7 17) #hardcoding modules that changed between these specific commits
#for num in "${temp[@]}"; do
#  mvn clean install -pl "${namelist[num]}" -DskipTests
#  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_frst
#done
#git checkout ff5a750
#for num in "${temp[@]}"; do
#  mvn clean install -pl "${namelist[num]}" -DskipTests
#  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_scnd
#done
#git checkout commit-report/japicmp_test
#
#if [ ! -d japicmp.jar ]; then
#  JAPICMP_VER=0.23.1
#  curl -fSL \
#  -o japicmp.jar \
#  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
#
#  # Ensure the download was successful (optional but recommended)
#  if [ ! -f japicmp.jar ]; then
#    echo "Error: Failed to download japicmp.jar."
#    exit 1
#  fi
#fi
#
#touch japicmp_test_pr.txt
#for num in "${temp[@]}"; do
#  ${namelist[num]} >> japicmp_test_pr.txt
#  OLD=commit_jars_frst/"${namelist[num]}"-"$version".jar
#  NEW=commit_jars_scnd/"${namelist[num]}"-"$version".jar
#  java -jar japicmp.jar \
#    --old "$OLD" \
#    --new "$NEW" \
#    --no-annotations \
#    --ignore-missing-classes \
#    --only-modified >> japicmp_test_pr.txt
#done
#
## add in code to remove japicmp.jar... maybe. depends on how the yaml file works
#
##javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/committer/JarIterator.java
##java -cp pinot-commit-reporter/target/classes org.apache.pinot.committer.JarIterator "$modnames"
##modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "\n</" )"
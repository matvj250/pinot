#!/bin/bash

temp="$(find . -type f -name "*1.4.0-SNAPSHOT.jar" | tr "\n" " ")"
temp=${temp//".//"}
IFS=' ' read -r -a namelist <<< "$temp"
echo "${namelist[@]}"

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
#touch japicmp_test.txt
#for num in "${temp[@]}"; do
#  ${namelist[num]} >> japicmp_test.txt
#  OLD=commit_jars_frst/"${namelist[num]}"-"$version".jar
#  NEW=commit_jars_scnd/"${namelist[num]}"-"$version".jar
#  java -jar japicmp.jar \
#    --old "$OLD" \
#    --new "$NEW" \
#    --no-annotations \
#    --ignore-missing-classes \
#    --only-modified >> japicmp_test.txt
#done
#
## add in code to remove japicmp.jar... maybe. depends on how the yaml file works
#
##javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/committer/JarIterator.java
##java -cp pinot-commit-reporter/target/classes org.apache.pinot.committer.JarIterator "$modnames"
##modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "\n</" )"
#!/bin/bash

if [ -d commit_jars_frst ]; then
  rm -r commit_jars_frst
fi
if [ -d commit_jars_scnd ]; then
  rm -r commit_jars_scnd/*
fi
mkdir commit_jars_frst
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" #there's a % at the end for some reason
modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
modnames=${modnames//"module"} # removes the word 'module' from the output
IFS=' ' read -r -a namelist <<< "$modnames"
echo "${namelist[0]}"
echo "${namelist[1]}"
echo "${namelist[2]}"
echo "${namelist[3]}"
git checkout 608f891
#mvn clean package -pl $ -DskipTests
for i in {0..1}; do
  mvn clean package -pl "${namelist[i]}" -DskipTests
  mv "${namelist[i]}"/target/"${namelist[i]}"-"$version".jar commit_jars_frst
done
git checkout commit-report/japicmp_test


#javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/committer/JarIterator.java
#java -cp pinot-commit-reporter/target/classes org.apache.pinot.committer.JarIterator "$modnames"
#modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "\n</" )"
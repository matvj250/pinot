#!/bin/bash

# theoretically, we'd need to make code for checking out the alternate branch
# but that isn't relevant right now, and this test code is in
# an alternate branch already
if [ -d commit_jars_frst ]; then
  rm -r commit_jars_frst
fi
if [ -d commit_jars_scnd ]; then
  rm -r commit_jars_scnd
fi
mkdir commit_jars_frst
mkdir commit_jars_scnd
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" #there's a % at the end for some reason
modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "/<>" | tr "\n" " ")"
modnames=${modnames//"module"} # removes the word 'module' from the output
IFS=' ' read -r -a namelist <<< "$modnames"
#echo "${namelist[0]}"
#echo "${namelist[1]}"
#echo "${namelist[2]}"
#echo "${namelist[3]}"
git checkout 608f891
#mvn clean package -pl $ -DskipTests
temp=(5 9) #hardcoding modules that changed between these specific commits
for i in {0..1}; do
  j="${temp[i]}"
  mvn clean package -pl "${namelist[j]}" -DskipTests
  mv "${namelist[j]}"/target/"${namelist[j]}"-"$version".jar commit_jars_frst
done
git checkout c7ce654
for i in {0..1}; do
  j="${temp[i]}"
  mvn clean package -pl "${namelist[j]}" -DskipTests
  mv "${namelist[j]}"/target/"${namelist[j]}"-"$version".jar commit_jars_frst
done
git checkout commit-report/japicmp_test

JAPICMP_VER=0.23.1
curl -sLo japicmp.jar "https://repo1.maven.org/maven2/org/japicmp/japicmp/$JAPICMP_VER/japicmp-$JAPICMP_VER-jar-with-dependencies.jar"

# Ensure the download was successful (optional but recommended)
if [ ! -f japicmp.jar ]; then
  echo "Error: Failed to download japicmp.jar."
  exit 1
fi

for i in {0..1}; do
  j="${temp[i]}"
  OLD=commit_jars_frst/"${namelist[j]}"-"$version".jar
  NEW=commit_jars_scnd/"${namelist[j]}"-"$version".jar
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    --error-on-source-incompatibility \
    --only-incompatible
done

#javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/committer/JarIterator.java
#java -cp pinot-commit-reporter/target/classes org.apache.pinot.committer.JarIterator "$modnames"
#modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "\n</" )"
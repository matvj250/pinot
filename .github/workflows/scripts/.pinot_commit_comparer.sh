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
#for item in "${namelist[@]}"; do
#  echo "$item"
#done

# use github cli to get pr-level operations(?)
# pr-level and commit level is different

# originally did 608f891 vs c7ce654 for common and controller (4 8)
# but there was some error with compiling controller that showed up in master too
# so pivoting to my broker-server commit
# same error with broker and server. I think something needs to be compiled
# before everything else. just gonna stick with pinot-spi for now
git checkout b061c55
#mvn clean package -pl $ -DskipTests
temp=(1) #hardcoding modules that changed between these specific commits
for num in "${temp[@]}"; do
  mvn clean install -pl "${namelist[num]}" -DskipTests
  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_frst
done
git checkout f0c9638
for num in "${temp[@]}"; do
  mvn clean install -pl "${namelist[num]}" -DskipTests
  mv "${namelist[num]}"/target/"${namelist[num]}"-"$version".jar commit_jars_scnd
done
git checkout commit-report/japicmp_test

echo "hello 0"

JAPICMP_VER=0.23.1
curl -fSL \
-o japicmp.jar \
"https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
echo "hello 1"

# Ensure the download was successful (optional but recommended)
if [ ! -f japicmp.jar ]; then
  echo "Error: Failed to download japicmp.jar."
  exit 1
fi

echo "hello 2"

for num in "${temp[@]}"; do
  OLD=commit_jars_frst/"${namelist[num]}"-"$version".jar
  NEW=commit_jars_scnd/"${namelist[num]}"-"$version".jar
  java -jar japicmp.jar \
    --old "$OLD" \
    --new "$NEW" \
    --error-on-binary-incompatibility \
    --only-incompatible \
    --ignore-missing-classes
done

echo "hello 3"

#javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/committer/JarIterator.java
#java -cp pinot-commit-reporter/target/classes org.apache.pinot.committer.JarIterator "$modnames"
#modnames="$(mvn -pl :pinot help:effective-pom | grep "<module>" | tr -d "\n</" )"
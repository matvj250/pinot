#!/bin/bash

# theoretically, we'd need to make code for checking out the alternate branch
# but that isn't relevant right now, and this test code is in
# an alternate branch (not master) already
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
#!/bin/bash

javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/reporter/CommitReporter.java

rm -f pinot-commit-reporter/resources/*

read -p "Old commit hash: " old
read -p "New commit hash: " new

if ! DIFF="$(git diff "$old".."$new" --name-status)"; then
  echo "git diff failed"
  exit 1
fi
echo "$DIFF" > pinot-commit-reporter/resources/temp_diff_file.txt
filename="commit_report_${old}_to_${new}"
touch pinot-commit-reporter/resources/"${filename}".txt
eval "$(java -cp pinot-commit-reporter/target/classes org.apache.pinot.reporter.CommitReporter pinot-commit-reporter/resources/temp_diff_file.txt pinot-commit-reporter/resources/"${filename}".txt)"

echo "Commit report between ${old} and ${new} available for review in pinot-commit-reporter/resources."
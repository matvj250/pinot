#!/bin/bash -x

javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/reporter/CommitReporter.java

read -pr "Old commit hash: " old
read -pr "New commit hash: " new

DIFF=$(git diff "$old" .. "$new" --name-status)
echo "$DIFF" > pinot-commit-reporter/resources/temp_diff_file.txt
$(java -cp pinot-commit-reporter/target/classes org.apache.pinot.reporter.CommitReporter pinot-commit-reporter/resources/temp_diff_file.txt)
rm pinot-spi-change-checker/temp_diff_file.txt

echo "Commit Report completed"
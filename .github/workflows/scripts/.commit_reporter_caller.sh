#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
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
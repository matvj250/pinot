javac -d pinot-commit-reporter/target/classes pinot-commit-reporter/src/main/java/org/apache/pinot/reporter/CommitReporter.java

for ((i=0; i < len_arr; i++)); do
  DIFF=$(git diff origin/master -- "${FILES_TO_CHECK[i]}")
  echo "$DIFF" > pinot-spi-change-checker/temp_diff_file.txt
  CONC=$(java -cp pinot-spi-change-checker/target/classes org.apache.pinot.changecheck.GitDiffChecker pinot-spi-change-checker/temp_diff_file.txt)
  rm pinot-spi-change-checker/temp_diff_file.txt
  if [[ "$CONC" != "0" ]]; then
    echo "Incorrect SPI change found in ${FILES_TO_CHECK[i]} at '$CONC'."
    exit 1
  fi
done

echo "No incorrect SPI changes found!"
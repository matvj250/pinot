package org.apache.pinot.changecheck;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * method name should not change
 * method should not be deleted
 * public API should not become private
 * method return type should not change
 * method return type annotation should not change
 * arguments should remain the same in count and type
 */

public class GitDiffChecker {

  public static String findDiff(String fileName) throws IOException {
    BufferedReader br = new BufferedReader(new FileReader(fileName));
    String li;
    Pattern funcDef = Pattern.compile("\\s*?\\b(public|private|protected)\\b.*?(.+?)[^{}]*?\\{");
    Pattern annoDef = Pattern.compile("\\s*?@.+?");
    while ((li = br.readLine()) != null) {
      if ((!li.isEmpty()) && (li.charAt(0) == '-') && (!li.startsWith("---"))) {
        Matcher matcher1 = funcDef.matcher(li.substring(1)); //gets rid of the '-'
        Matcher matcher2 = annoDef.matcher(li.substring(1));
        if (matcher1.matches() || matcher2.matches()) {
          // return line number of spi change in original code
          // minus the repetitive lines at the top of git diff output
          return li;
        }
      }
    }
    return "";
  }

  public static void main(String[] args) throws IOException {
    System.out.println(findDiff(args[0]));
  }
}


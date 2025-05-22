package org.apache.pinot.reporter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.ProcessBuilder;
import java.util.Map;


public class CommitReporter {

  public static File diff(String earlyCommit, String lateCommit) throws IOException {
    String command = "git diff " + earlyCommit + " " + lateCommit + " --name-status";
    ProcessBuilder pb = new ProcessBuilder(command);
    File log = new File("log");
    pb.redirectErrorStream(true);
    pb.redirectOutput(ProcessBuilder.Redirect.appendTo(log));
    Process process = pb.start();
    return log;
  }

  public static void assign(File log) throws IOException {
    try (BufferedReader br = new BufferedReader(new FileReader(log))) {
      String line;
      while ((line = br.readLine()) != null) {
        System.out.println(line);
      }
    }
  }

  public static void main(String[] args) throws IOException {
    assign(diff(args[0], args[1]));
  }

}

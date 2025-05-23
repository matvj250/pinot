package org.apache.pinot.reporter;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CommitReporter {

//  public static File diff(String earlyCommit, String lateCommit) throws IOException {
//    String command = "git diff " + earlyCommit + " " + lateCommit + " --name-status";
//    ProcessBuilder pb = new ProcessBuilder(command);
//    File log = new File("log");
//    pb.redirectErrorStream(true);
//    pb.redirectOutput(ProcessBuilder.Redirect.appendTo(log));
//    Process process = pb.start();
//    return log;
//  }

  public static Map<String, String> assign(File log) throws IOException {
    Map<String, String> pairing = new HashMap<>();
    try (BufferedReader br = new BufferedReader(new FileReader(log))) {
      String line;
      while ((line = br.readLine()) != null) {
        int space = line.indexOf("\t");
        pairing.put(line.substring(space+1), line.substring(0, space));
      }
    }
    return pairing;
  }

  public static void parse(Map<String, String> pairing, File output) throws IOException {
    try (BufferedWriter bw = new BufferedWriter(new FileWriter(output))) {
      for (String key : pairing.keySet()) {
        String value = pairing.get(key);
        switch (value) {
          case "A":
            bw.write(key + " - added");
            bw.newLine();
            break;
          case "M":
            bw.write(key + " - modified");
            bw.newLine();
            break;
          case "D":
            bw.write(key + " - deleted");
            bw.newLine();
            break;
          default:
            bw.write(key + " - changed in some other way");
            bw.newLine();
            break;
        }
      }
    }
  }

//  public void tree() {
//    Run.initGenerators(); // registers the available parsers
//    String file = "myfile.java";
//    TreeContext tc = TreeGenerators.getInstance().getTree(file); // retrieves and applies the default parser for the file
//    Tree t = tc.getRoot();
//  }

  public static void main(String[] args) throws IOException {
//    assign(diff(args[0], args[1]));
    parse(assign(new File(args[0])), new File(args[1]));
  }

}

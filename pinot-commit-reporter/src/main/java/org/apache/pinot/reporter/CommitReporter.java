/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.apache.pinot.reporter;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public final class CommitReporter {

  private CommitReporter() {
  }

  public static Map<String, String> assign(File log) throws IOException {
    Map<String, String> pairing = new HashMap<>();
    try (BufferedReader br = new BufferedReader(new FileReader(log))) {
      String line;
      while ((line = br.readLine()) != null) {
        int space = line.indexOf("\t");
        pairing.put(line.substring(space + 1), line.substring(0, space));
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

  public static void main(String[] args) throws IOException {
    parse(assign(new File(args[0])), new File(args[1]));
  }
}

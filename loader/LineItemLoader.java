import java.io.BufferedReader;
import java.io.FileReader;
import java.io.File;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class LineItemLoader implements Runnable {

  private static final int BATCH_SIZE = 50;
  private static final int MAX_CONCURRENCY = 72;

  private String fileName;
  private String connectString;
  private String username;
  private String password;

  public LineItemLoader(String fileName, String connectString, String username, String password) {
    this.fileName = fileName;
    this.connectString = connectString;
    this.username = username;
    this.password = password;
  }

  public void run() {
    try {
      Class.forName("org.mariadb.jdbc.Driver");
      Connection con =
          DriverManager.getConnection(connectString, username, password);
      con.setAutoCommit(false);
      PreparedStatement stmt =
          con.prepareStatement(
              "INSERT INTO lineitem(l_orderkey, l_partkey, l_suppkey, l_linenumber, l_quantity,"
                  + " l_extendedprice, l_discount, l_tax, l_returnflag, l_linestatus, l_shipdate,"
                  + " l_commitdate, l_receiptdate, l_shipinstruct, l_shipmode, l_comment) VALUES"
                  + " (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

      BufferedReader reader = new BufferedReader(new FileReader(fileName));
      System.out.println(String.format("Processing %s", fileName));
      String line;
      int count = 0;
      while ((line = reader.readLine()) != null) {
        String[] parts = line.split("\\|");

        stmt.setInt(1, Integer.parseInt(parts[0].trim()));
        stmt.setInt(2, Integer.parseInt(parts[1].trim()));
        stmt.setInt(3, Integer.parseInt(parts[2].trim()));
        stmt.setInt(4, Integer.parseInt(parts[3].trim()));
        stmt.setDouble(5, Double.parseDouble(parts[4].trim()));
        stmt.setDouble(6, Double.parseDouble(parts[5].trim()));
        stmt.setDouble(7, Double.parseDouble(parts[6].trim()));
        stmt.setDouble(8, Double.parseDouble(parts[7].trim()));
        stmt.setString(9, parts[8].trim());
        stmt.setString(10, parts[9].trim());
        stmt.setDate(11, Date.valueOf(parts[10].trim()));
        stmt.setDate(12, Date.valueOf(parts[11].trim()));
        stmt.setDate(13, Date.valueOf(parts[12].trim()));
        stmt.setString(14, parts[13].trim());
        stmt.setString(15, parts[14].trim());
        stmt.setString(16, parts[15].trim());

        stmt.addBatch();
        count++;

        if (count % BATCH_SIZE == 0) {
          stmt.executeBatch();
	  con.commit();
        }
      }

      stmt.executeBatch();
      con.commit();

      reader.close();
      stmt.close();
      con.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public static void main(String[] args) {

    String connectString = "jdbc:mysql://localhost/tpch";
    String username = "xbench";
    String password = "password";
    String dirPath = "/tmp";
    int fileId;
    int maxFiles;

    // Parse command line arguments
    // Example usage: java TpcHLoader -f 10 -c "jdbc:mariadb://localhost:3306/tpc-h" -u user -p password -d /path/to/files
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case "-f":
          maxFiles = Integer.parseInt(args[++i]);
          break;
        case "-c":
          connectString = args[++i];
          break;
        case "-u":
          username = args[++i];
          break;
        case "-p":
          password = args[++i];
          break;
        case "-d":
          dirPath = args[++i];
          break;
      }
    }

    List<String> fileList = getFileList(dirPath);
    ExecutorService executor = Executors.newFixedThreadPool(MAX_CONCURRENCY);

    for (String file : fileList) {
      //System.out.println(String.format("Processing %s", file));
      executor.submit(new LineItemLoader(file, connectString, username, password));
    }
    executor.shutdown();
    try {
      executor.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  private static List<String> getFileList(String dirPath) {
    List<String> fileList = new ArrayList<>();

    File directory = new File(dirPath);
    if (!directory.exists()) {
      throw new IllegalArgumentException("Data directory does not exist");
    }

    File[] files = directory.listFiles();
    if (files == null) {
      throw new IllegalArgumentException("No files found in data directory");
    }

    for (File file : files) {
      if (file.isFile() && file.getName().startsWith("lineitem")) {
        fileList.add(file.getAbsolutePath());
      }
    }

    return fileList;
  }
}

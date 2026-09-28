import java.io.*;

public class Catches {
    static void load() throws FileNotFoundException { }

    public static void main(String[] args) {
        try { load(); }
        catch (FileNotFoundException e) { }        // L1
        catch (IOException e) { }                  // L2
        try { load(); }
        catch (Exception e) { }                    // L3
        catch (RuntimeException e) { }             // L4
        try { System.out.print(""); }
        catch (RuntimeException e) { }             // L5
    }
}

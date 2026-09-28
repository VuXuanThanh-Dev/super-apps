import java.io.*;
import java.util.concurrent.Callable;

public class Lam {
    public static void main(String[] args) throws Exception {
        Callable<String> c = () -> { throw new IOException(); };
    }
}

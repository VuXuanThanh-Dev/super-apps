import java.io.*;
import java.util.concurrent.Callable;

public class Lam {
    public static void main(String[] args) throws Exception {
        java.util.function.Supplier<String> s = () -> { throw new Exception(); };
    }
}

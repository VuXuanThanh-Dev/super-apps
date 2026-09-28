import java.util.*;

public class Opt {
    static String load() {
        System.out.print("load ");
        return "db";
    }

    public static void main(String[] args) {
        Optional<String> o = Optional.of("cache");
        String a = o.orElse(load());
        String b = o.orElseGet(() -> load());
        String c = Optional.<String>empty().map(String::toUpperCase).orElseGet(() -> "none");
        System.out.println(a + " " + b + " " + c);
    }
}

import java.util.stream.*;
public class P { public static void main(String[] a) {
    Stream.of(1, 2).peek(System.out::print); System.out.println("done"); } }

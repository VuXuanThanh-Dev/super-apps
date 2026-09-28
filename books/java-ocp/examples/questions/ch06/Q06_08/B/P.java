import java.util.stream.*;
public class P { public static void main(String[] a) {
    System.out.println(Stream.<String>empty().allMatch(x -> x.length() > 100)); } }

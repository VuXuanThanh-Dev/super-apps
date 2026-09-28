import java.util.*;
public class P { public static void main(String[] a) {
    System.out.println(List.of(1).stream().parallel().sequential().isParallel()); } }

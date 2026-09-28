import java.util.*;
public class P { public static void main(String[] a) {
    System.out.println(List.of(1, 2, 3).parallelStream().mapToInt(i -> i).sum()); } }

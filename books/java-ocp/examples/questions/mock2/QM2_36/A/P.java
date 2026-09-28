import java.util.*;
public class P { public static void main(String[] a) {
    StringBuilder sb = new StringBuilder();
    List.of(1, 2, 3, 4, 5, 6, 7, 8).parallelStream().forEachOrdered(sb::append);
    System.out.println(sb); } }

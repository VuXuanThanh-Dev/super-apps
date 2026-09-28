import java.util.*;
public class P { public static void main(String[] a) {
    Optional.empty().map(v -> { System.out.print("called "); return v; });
    System.out.println("done"); } }

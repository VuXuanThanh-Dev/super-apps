import java.util.*;
public class P {
    static String x() { System.out.print("evaluated "); return "x"; }
    public static void main(String[] a) { System.out.println(Optional.of("v").orElse(x())); } }

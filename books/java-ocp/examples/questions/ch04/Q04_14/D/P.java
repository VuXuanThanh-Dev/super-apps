public class P { public static void main(String[] a) {
    try { Integer.parseInt("x"); }
    catch (NumberFormatException | NullPointerException e) { e = null; } } }

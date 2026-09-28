import java.util.*;
public class Main { public static void main(String[] a) {
    Locale.setDefault(Locale.US);
    System.out.println(ResourceBundle.getBundle("B", Locale.JAPAN).getString("k")); } }

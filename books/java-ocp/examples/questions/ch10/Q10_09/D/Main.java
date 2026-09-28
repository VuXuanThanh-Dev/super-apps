import java.util.*;
public class Main { public static void main(String[] a) {
    try { ResourceBundle.getBundle("K").getString("Greeting"); System.out.println("found"); }
    catch (MissingResourceException e) { System.out.println("missing"); } } }

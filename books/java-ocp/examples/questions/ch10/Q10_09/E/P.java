import java.text.*;
import java.util.*;
public class P { public static void main(String[] a) throws ParseException {
    System.out.println(NumberFormat.getInstance(Locale.US).parse("1,5")); } }

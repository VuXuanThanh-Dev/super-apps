public class Scope {
    public static void main(String[] args) {
        Object o = "abc";
        if (o instanceof String s && s.length() > 2) System.out.println(s);   // L1
        if (o instanceof String t || t.isEmpty()) System.out.println("?");    // L2
        if (!(o instanceof String u)) return;
        System.out.println(u.length());                                         // L3
        int s = 5;                                                              // L4
    }
}

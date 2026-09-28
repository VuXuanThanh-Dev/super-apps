public class Pool {
    public static void main(String[] args) {
        final String a = "Ja";
        String b = "Ja";
        String c = a + "va";
        String d = b + "va";
        String e = "Java";
        System.out.println((c == e) + " " + (d == e) + " " + (d.intern() == e) + " " + c.equals(d));
    }
}

class P {
    String n = "P";
    String get() { return n; }
    static String s() { return "sP"; }
}

class C extends P {
    String n = "C";
    @Override String get() { return n; }
    static String s() { return "sC"; }
}

public class Poly {
    public static void main(String[] args) {
        P p = new C();
        System.out.println(p.n + " " + p.get() + " " + p.s() + " " + ((C) p).n);
    }
}

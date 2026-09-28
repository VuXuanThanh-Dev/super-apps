class A {
    void m(Object o) { System.out.print("AO "); }
    void m(String s) { System.out.print("AS "); }
}

class B extends A {
    @Override void m(Object o) { System.out.print("BO "); }
}

public class Mix {
    public static void main(String[] args) {
        A a = new B();
        Object o = "x";
        a.m(o);
        a.m("x");
        a.m(null);
    }
}

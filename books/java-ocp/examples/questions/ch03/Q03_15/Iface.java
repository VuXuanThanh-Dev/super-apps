public class Iface {
    interface A { default String hi() { return "A"; } }
    interface B extends A { default String hi() { return "B" + A.super.hi(); } }
    interface C extends A { }
    static class X implements B, C { }

    public static void main(String[] args) {
        System.out.println(new X().hi());
    }
}

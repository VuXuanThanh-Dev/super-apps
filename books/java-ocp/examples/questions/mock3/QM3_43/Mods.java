public class Mods {
    abstract static class A { abstract void f(); }                  // L1
    abstract static class B { final abstract void f(); }            // L2
    abstract static class C { private abstract void f(); }          // L3
    abstract static class D { static void f() { } }                 // L4
    static final class E extends A { void f() { } }                 // L5
    abstract static class F { abstract static void f(); }           // L6

    public static void main(String[] args) { }
}

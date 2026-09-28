public class Ctor {
    static class Base { Base(int x) { } }
    static class A extends Base { A() { super(1); } }          // L1
    static class B extends Base { B() { } }                    // L2
    static class C extends Base { C(int x) { super(x); } }     // L3
    static class D extends Base { }                            // L4
    static class E { final int v; E() { } }                    // L5

    public static void main(String[] args) { }
}

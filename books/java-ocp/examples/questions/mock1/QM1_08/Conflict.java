public class Conflict {
    interface Walk { default String go() { return "walk"; } }
    interface Run { default String go() { return "run"; } }
    interface Fly { String go(); }

    static class A implements Walk, Run { }                                                   // L1
    static class B implements Walk, Run { public String go() { return Walk.super.go(); } }   // L2
    static abstract class C implements Walk, Fly { }                                          // L3
    static class D implements Fly { public String go() { return "d"; } }                      // L4
    static class E implements Walk { public String go() { return "e" + Walk.super.go(); } }  // L5

    public static void main(String[] args) { }
}

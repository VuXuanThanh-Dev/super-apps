public class Enums {
    enum Color { RED, GREEN; Color() { } }                                       // L1
    enum Size { S, M; public Size() { } }                                        // L2
    enum Level { LOW(1), HIGH(2); final int v; Level(int v) { this.v = v; } }    // L3
    enum Mode { ON { void f() { } }, OFF; abstract void f(); }                   // L4
    enum Pet { int legs; DOG, CAT; }                                             // L5

    public static void main(String[] args) { }
}

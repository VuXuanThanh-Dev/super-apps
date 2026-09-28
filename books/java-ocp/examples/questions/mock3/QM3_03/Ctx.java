public class Ctx {
    int count;
    static int total;

    static void s() { total++; }
    void i() { count++; total++; s(); }                    // L1
    static void t() { count++; }                           // L2
    static void u() { i(); }                               // L3
    static void v() { new Ctx().i(); this.total = 1; }     // L4

    public static void main(String[] args) { s(); }        // L5
}

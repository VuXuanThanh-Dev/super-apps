public class Amb {
    static void m(Integer a, long b) { }
    static void m(long a, Integer b) { }

    public static void main(String[] args) {
        m(1, 2);      // L1
        m(1L, 2);     // L2
        m(1, 2L);     // L3
    }
}

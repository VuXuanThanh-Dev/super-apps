public class Sync {
    private final Object lock = new Object();
    private int count;

    synchronized void a() { count++; }                        // L1
    void b() { synchronized (lock) { count++; } }             // L2
    void c() { synchronized (count) { count++; } }            // L3
    static synchronized void d() { }                          // L4
    synchronized Sync() { }                                   // L5

    public static void main(String[] args) { }
}

public class P {
    static final Object LOCK = new Object();
    public static void main(String[] a) {
        synchronized (LOCK) { synchronized (LOCK) { System.out.println("re-entered"); } }
    }
}

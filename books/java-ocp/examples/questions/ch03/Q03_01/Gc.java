import java.lang.ref.Reference;
import java.lang.ref.WeakReference;

public class Gc {
    public static void main(String[] args) throws Exception {
        Object a = new Object();   // obj1
        Object b = new Object();   // obj2
        Object c = new Object();   // obj3
        WeakReference<Object> w1 = new WeakReference<>(a);
        WeakReference<Object> w2 = new WeakReference<>(b);
        WeakReference<Object> w3 = new WeakReference<>(c);
        a = b;
        c = a;
        b = null;
        // line X: ép GC chạy (SerialGC + System.gc()) và đếm object đã bị thu hồi
        System.gc();
        Thread.sleep(200);
        int cleared = (w1.get() == null ? 1 : 0) + (w2.get() == null ? 1 : 0) + (w3.get() == null ? 1 : 0);
        Reference.reachabilityFence(a);   // giữ a, c "còn sống" như tại line X
        Reference.reachabilityFence(c);
        System.out.println(cleared);
    }
}

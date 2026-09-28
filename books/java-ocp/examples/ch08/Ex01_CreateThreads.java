// objective: 8.1
// 5 cách tạo luồng (thread): extends Thread, Runnable, Thread.Builder (platform/virtual), startVirtualThread.
public class Ex01_CreateThreads {
    static class Worker extends Thread {
        Worker() { super("worker-1"); }
        @Override public void run() { System.out.println("extends Thread: " + getName()); }
    }

    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Worker();
        t1.start();
        t1.join();                                          // đợi t1 kết thúc

        Thread t2 = new Thread(() -> System.out.println("Runnable lambda: " + Thread.currentThread().getName()), "task-2");
        t2.start();
        t2.join();

        Thread t3 = Thread.ofPlatform().name("platform-3").start(
                () -> System.out.println("platform: virtual? " + Thread.currentThread().isVirtual()));
        t3.join();

        Thread t4 = Thread.ofVirtual().name("virtual-4").start(
                () -> System.out.println("virtual: virtual? " + Thread.currentThread().isVirtual()
                        + ", daemon? " + Thread.currentThread().isDaemon()));
        t4.join();

        Thread t5 = Thread.startVirtualThread(() -> System.out.println("startVirtualThread, name='"
                + Thread.currentThread().getName() + "'"));   // virtual thread mặc định không có tên
        t5.join();

        Thread unstarted = Thread.ofVirtual().unstarted(() -> { });
        System.out.println("unstarted state: " + unstarted.getState());
        System.out.println("main is virtual? " + Thread.currentThread().isVirtual());
    }
}

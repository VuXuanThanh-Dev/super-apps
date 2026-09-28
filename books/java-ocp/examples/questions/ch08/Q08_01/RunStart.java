public class RunStart {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> System.out.print(Thread.currentThread().getName() + " "), "worker");
        t.run();
        t.start();
        t.join();
    }
}

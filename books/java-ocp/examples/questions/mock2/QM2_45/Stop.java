public class Stop {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                Thread.onSpinWait();
            }
            System.out.print("stopped ");
        });
        t.start();
        t.interrupt();
        t.join();
        System.out.println(t.getState());
    }
}

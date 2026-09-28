public class States {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> { });
        System.out.print(t.getState() + " ");
        t.start();
        t.join();
        System.out.print(t.getState() + " " + t.isAlive());
    }
}

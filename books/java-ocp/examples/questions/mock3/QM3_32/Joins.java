public class Joins {
    public static void main(String[] args) throws InterruptedException {
        StringBuffer sb = new StringBuffer();
        Thread a = new Thread(() -> sb.append("a"));
        Thread b = new Thread(() -> {
            try { a.join(); } catch (InterruptedException e) { }
            sb.append("b");
        });
        a.start();
        b.start();
        b.join();
        sb.append("m");
        System.out.println(sb + " " + a.isAlive() + " " + b.isDaemon());
    }
}

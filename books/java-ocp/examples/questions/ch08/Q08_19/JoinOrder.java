public class JoinOrder {
    public static void main(String[] args) throws InterruptedException {
        StringBuilder sb = new StringBuilder();
        Thread t = new Thread(() -> sb.append("T"));
        sb.append("A");
        t.start();
        t.join();
        sb.append("B");
        System.out.println(sb);
    }
}

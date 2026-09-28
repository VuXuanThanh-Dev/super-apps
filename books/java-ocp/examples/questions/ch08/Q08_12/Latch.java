import java.util.concurrent.CountDownLatch;

public class Latch {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch latch = new CountDownLatch(2);
        latch.countDown();
        latch.countDown();
        latch.countDown();
        latch.await();
        System.out.println(latch.getCount());
    }
}

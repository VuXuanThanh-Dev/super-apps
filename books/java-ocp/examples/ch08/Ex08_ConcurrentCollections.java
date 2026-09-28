// objective: 8.2, 8.3
// Collection an toàn cho đa luồng: ConcurrentHashMap, CopyOnWriteArrayList, BlockingQueue.
import java.util.*;
import java.util.concurrent.*;

public class Ex08_ConcurrentCollections {
    public static void main(String[] args) throws Exception {
        ConcurrentHashMap<String, Integer> hits = new ConcurrentHashMap<>();
        try (ExecutorService ex = Executors.newFixedThreadPool(4)) {
            for (int i = 0; i < 1000; i++) {
                String page = (i % 2 == 0) ? "home" : "about";
                ex.submit(() -> hits.merge(page, 1, Integer::sum));   // merge là nguyên tử
            }
        }
        System.out.println(new TreeMap<>(hits));

        List<String> cow = new CopyOnWriteArrayList<>(List.of("a", "b"));
        for (String s : cow) cow.add(s + "!");          // không có ConcurrentModificationException
        System.out.println(cow);                        // vòng lặp duyệt "ảnh chụp" (snapshot) cũ

        BlockingQueue<Integer> queue = new ArrayBlockingQueue<>(2);
        Thread producer = new Thread(() -> {
            try {
                for (int i = 1; i <= 5; i++) queue.put(i);   // put chặn khi hàng đợi đầy
                queue.put(-1);                              // tín hiệu kết thúc
            } catch (InterruptedException e) { }
        });
        producer.start();
        StringBuilder got = new StringBuilder();
        for (int v; (v = queue.take()) != -1; ) got.append(v).append(' ');  // take chặn khi rỗng
        System.out.println("consumed: " + got.toString().trim());
        System.out.println("offer on full: " + new ArrayBlockingQueue<Integer>(1) {{ offer(1); }}.offer(2));

        Map<String, Integer> sync = Collections.synchronizedMap(new HashMap<>());
        sync.put("x", 1);
        System.out.println(sync + " " + new ConcurrentSkipListSet<>(List.of(3, 1, 2)));
    }
}

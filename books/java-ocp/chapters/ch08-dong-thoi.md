# Chương 8 — Đồng thời (Managing Concurrent Code Execution)

## Mục tiêu

- 8.1 Tạo **platform thread** và **virtual thread**; dùng `Runnable` và `Callable`; quản lý vòng đời thread; dùng các
  `ExecutorService` và concurrent API để chạy task.
- 8.2 Viết code an toàn luồng (thread-safe) bằng cơ chế khoá (locking) và concurrent API.
- 8.3 Xử lý collection đồng thời và dùng parallel stream.

## Giải thích đơn giản

**Thread (luồng)** là một dòng chạy code độc lập trong cùng chương trình. Nhiều thread chạy "cùng lúc" và **dùng chung
bộ nhớ** (heap). Điều đó nhanh, nhưng nguy hiểm: hai thread cùng sửa một biến có thể làm mất dữ liệu (race condition).

Java 21 có hai loại thread:

| | Platform thread | Virtual thread |
|---|---|---|
| Là gì | Bọc một thread của hệ điều hành | Thread nhẹ do JVM quản lý, chạy "trên" vài platform thread (carrier) |
| Chi phí | Đắt (≈ MB bộ nhớ stack), vài nghìn là nhiều | Rẻ, có thể tạo hàng trăm nghìn |
| Hợp với | Việc nặng CPU | Việc chờ I/O (gọi HTTP, DB, sleep) |
| Tạo | `new Thread(r)`, `Thread.ofPlatform()` | `Thread.ofVirtual()`, `Thread.startVirtualThread(r)`, `Executors.newVirtualThreadPerTaskExecutor()` |
| Daemon | Tuỳ chọn | Luôn là daemon |

Thay vì tự quản lý thread, ta giao **task** (`Runnable` hoặc `Callable`) cho một **ExecutorService**.

## Ví dụ

Code trong `examples/ch08/`. Chạy lại: `python3 tools/book.py examples ch08`. Output thật, JDK 21.0.10.
Các ví dụ được viết để output **luôn giống nhau** (dùng `join`, `Future.get`, latch…); chỗ nào kết quả thật sự thay đổi
mỗi lần chạy, ví dụ chỉ in điều luôn đúng và ghi chú rõ.

### 1. Tạo thread

<!-- EX:Ex01_CreateThreads -->
`examples/ch08/Ex01_CreateThreads.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
extends Thread: worker-1
Runnable lambda: task-2
platform: virtual? false
virtual: virtual? true, daemon? true
startVirtualThread, name=''
unstarted state: NEW
main is virtual? false
```
<!-- /EX -->

### 2. Vòng đời thread

<!-- EX:Ex02_Lifecycle -->
`examples/ch08/Ex02_Lifecycle.java`

```java
// objective: 8.1
// Vòng đời thread: NEW → RUNNABLE → (BLOCKED/WAITING/TIMED_WAITING) → TERMINATED; run() vs start().
import java.util.concurrent.CountDownLatch;

public class Ex02_Lifecycle {
    public static void main(String[] args) throws Exception {
        CountDownLatch started = new CountDownLatch(1);
        Thread t = new Thread(() -> {
            started.countDown();
            try { Thread.sleep(2_000); } catch (InterruptedException e) {
                System.out.println("bị interrupt khi đang sleep → InterruptedException");
            }
        }, "sleeper");
        System.out.println("1: " + t.getState());          // NEW
        t.start();
        started.await();
        while (t.getState() != Thread.State.TIMED_WAITING) Thread.onSpinWait();
        System.out.println("2: " + t.getState());          // TIMED_WAITING (đang sleep)
        t.interrupt();                                      // đánh thức sớm
        t.join();
        System.out.println("3: " + t.getState() + ", alive? " + t.isAlive());

        Thread r = new Thread(() -> System.out.println("run() chạy trên thread: " + Thread.currentThread().getName()), "other");
        r.run();                                            // KHÔNG tạo thread mới
        r.start();
        r.join();
        try {
            r.start();                                      // start lần 2
        } catch (IllegalThreadStateException e) {
            System.out.println("IllegalThreadStateException: không start() hai lần");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
1: NEW
2: TIMED_WAITING
bị interrupt khi đang sleep → InterruptedException
3: TERMINATED, alive? false
run() chạy trên thread: main
run() chạy trên thread: other
IllegalThreadStateException: không start() hai lần
```
<!-- /EX -->

### 3. ExecutorService, Callable, Future

<!-- EX:Ex03_ExecutorCallable -->
`examples/ch08/Ex03_ExecutorCallable.java`

```java
// objective: 8.1
// ExecutorService: submit Runnable/Callable, Future.get, invokeAll, shutdown, awaitTermination.
import java.util.List;
import java.util.concurrent.*;

public class Ex03_ExecutorCallable {
    public static void main(String[] args) throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(2);
        Callable<Integer> sum = () -> {
            int s = 0;
            for (int i = 1; i <= 100; i++) s += i;
            return s;
        };
        Future<Integer> f = pool.submit(sum);
        Future<?> r = pool.submit(() -> System.out.println("Runnable không trả về giá trị"));
        System.out.println("sum = " + f.get() + ", runnable result = " + r.get() + ", done? " + f.isDone());

        List<Callable<String>> tasks = List.of(() -> "a", () -> "b", () -> "c");
        StringBuilder sb = new StringBuilder();
        for (Future<String> fu : pool.invokeAll(tasks)) sb.append(fu.get());   // kết quả theo đúng thứ tự task
        System.out.println("invokeAll: " + sb);

        Future<Integer> failing = pool.submit(() -> 1 / 0);
        try {
            failing.get();
        } catch (ExecutionException e) {
            System.out.println("ExecutionException, cause: " + e.getCause());
        }
        Future<String> slow = pool.submit(() -> { Thread.sleep(3_000); return "late"; });
        try {
            slow.get(100, TimeUnit.MILLISECONDS);
        } catch (TimeoutException e) {
            System.out.println("TimeoutException; cancel → " + slow.cancel(true) + ", cancelled? " + slow.isCancelled());
        }

        pool.shutdown();                                   // không nhận task mới, chạy nốt task cũ
        System.out.println("isShutdown=" + pool.isShutdown() + " terminated=" + pool.awaitTermination(5, TimeUnit.SECONDS));
        try {
            pool.submit(() -> "x");
        } catch (RejectedExecutionException e) {
            System.out.println("RejectedExecutionException sau shutdown");
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
Runnable không trả về giá trị
sum = 5050, runnable result = null, done? true
invokeAll: abc
ExecutionException, cause: java.lang.ArithmeticException: / by zero
TimeoutException; cancel → true, cancelled? true
isShutdown=true terminated=true
RejectedExecutionException sau shutdown
```
<!-- /EX -->

### 4. Virtual thread executor

<!-- EX:Ex04_VirtualExecutor -->
`examples/ch08/Ex04_VirtualExecutor.java`

```java
// objective: 8.1
// Virtual threads: một thread cho mỗi task, rất rẻ; ExecutorService là AutoCloseable (close() đợi task xong).
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class Ex04_VirtualExecutor {
    public static void main(String[] args) throws Exception {
        List<Future<Integer>> results = new ArrayList<>();
        try (ExecutorService ex = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 1; i <= 10_000; i++) {
                int n = i;
                results.add(ex.submit(() -> {
                    Thread.sleep(Duration.ofMillis(10));   // "chặn" (blocking) nhưng virtual thread nhả carrier thread
                    return n;
                }));
            }
        }                                                  // close() = shutdown + đợi mọi task kết thúc
        long total = 0;
        for (Future<Integer> f : results) total += f.get();
        System.out.println("10000 virtual tasks, total = " + total);

        try (var ex = Executors.newVirtualThreadPerTaskExecutor()) {
            Future<Boolean> isVirtual = ex.submit(() -> Thread.currentThread().isVirtual());
            System.out.println("task chạy trên virtual thread? " + isVirtual.get());
        }
    }
}
```

Output thật (JDK 21.0.10):

```text
10000 virtual tasks, total = 50005000
task chạy trên virtual thread? true
```
<!-- /EX -->

### 5. ScheduledExecutorService

<!-- EX:Ex05_Scheduled -->
`examples/ch08/Ex05_Scheduled.java`

```java
// objective: 8.1
// ScheduledExecutorService: chạy sau một khoảng trễ, hoặc lặp lại định kỳ.
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex05_Scheduled {
    public static void main(String[] args) throws Exception {
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ScheduledFuture<String> later = ses.schedule(() -> "chạy sau 100ms", 100, TimeUnit.MILLISECONDS);
        System.out.println(later.get());

        AtomicInteger ticks = new AtomicInteger();
        CountDownLatch three = new CountDownLatch(3);
        ScheduledFuture<?> repeat = ses.scheduleAtFixedRate(() -> {
            ticks.incrementAndGet();
            three.countDown();
        }, 0, 50, TimeUnit.MILLISECONDS);
        three.await();
        repeat.cancel(false);
        System.out.println("ticks >= 3 ? " + (ticks.get() >= 3) + ", cancelled? " + repeat.isCancelled());
        ses.shutdown();
        System.out.println("terminated: " + ses.awaitTermination(2, TimeUnit.SECONDS));
    }
}
```

Output thật (JDK 21.0.10):

```text
chạy sau 100ms
ticks >= 3 ? true, cancelled? true
terminated: true
```
<!-- /EX -->

### 6. Race condition

<!-- EX:Ex06_RaceCondition -->
`examples/ch08/Ex06_RaceCondition.java`

```java
// objective: 8.2
// Race condition: count++ không nguyên tử (atomic). So sánh với synchronized và AtomicInteger.
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex06_RaceCondition {
    static int unsafe = 0;
    static int safe = 0;
    static final Object LOCK = new Object();
    static final AtomicInteger atomic = new AtomicInteger();

    public static void main(String[] args) throws Exception {
        int threads = 4, perThread = 100_000;
        try (ExecutorService ex = Executors.newFixedThreadPool(threads)) {
            for (int t = 0; t < threads; t++) {
                ex.submit(() -> {
                    for (int i = 0; i < perThread; i++) {
                        unsafe++;                                  // đọc - cộng - ghi: có thể mất cập nhật
                        synchronized (LOCK) { safe++; }            // một thread một lúc
                        atomic.incrementAndGet();                  // compare-and-set bên trong
                    }
                });
            }
        }
        int expected = threads * perThread;
        System.out.println("expected    = " + expected);
        System.out.println("synchronized= " + safe);
        System.out.println("atomic      = " + atomic.get());
        System.out.println("unsafe <= expected? " + (unsafe <= expected) + " (giá trị thật thay đổi mỗi lần chạy)");
    }
}
```

Output thật (JDK 21.0.10):

```text
expected    = 400000
synchronized= 400000
atomic      = 400000
unsafe <= expected? true (giá trị thật thay đổi mỗi lần chạy)
```
<!-- /EX -->

### 7. Lock

<!-- EX:Ex07_Locks -->
`examples/ch08/Ex07_Locks.java`

```java
// objective: 8.2
// ReentrantLock: lock()/unlock() trong finally, tryLock(), khoá "reentrant", ReadWriteLock.
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.*;

public class Ex07_Locks {
    static final ReentrantLock lock = new ReentrantLock();
    static int balance = 100;

    static void withdraw(int amount) {
        lock.lock();
        try {
            if (balance >= amount) balance -= amount;
            nested();                                     // cùng thread lấy lại khoá được (reentrant)
        } finally {
            lock.unlock();                                // LUÔN mở khoá trong finally
        }
    }

    static void nested() {
        lock.lock();
        try { System.out.println("hold count = " + lock.getHoldCount()); } finally { lock.unlock(); }
    }

    public static void main(String[] args) throws Exception {
        withdraw(30);
        System.out.println("balance = " + balance + ", locked now? " + lock.isLocked());

        lock.lock();                                      // main giữ khoá
        Thread other = new Thread(() -> {
            try {
                boolean got = lock.tryLock(100, TimeUnit.MILLISECONDS);
                System.out.println("other tryLock: " + got);
                if (got) lock.unlock();
            } catch (InterruptedException e) { }
        });
        other.start();
        other.join();
        lock.unlock();

        try {
            lock.unlock();                                // mở khoá khi không giữ
        } catch (IllegalMonitorStateException e) {
            System.out.println("IllegalMonitorStateException");
        }

        ReadWriteLock rw = new ReentrantReadWriteLock();
        rw.readLock().lock();
        rw.readLock().lock();                             // nhiều reader cùng lúc được
        System.out.println("read locks = " + ((ReentrantReadWriteLock) rw).getReadLockCount());
        rw.readLock().unlock();
        rw.readLock().unlock();
    }
}
```

Output thật (JDK 21.0.10):

```text
hold count = 2
balance = 70, locked now? false
other tryLock: false
IllegalMonitorStateException
read locks = 2
```
<!-- /EX -->

### 8. Concurrent collections

<!-- EX:Ex08_ConcurrentCollections -->
`examples/ch08/Ex08_ConcurrentCollections.java`

```java
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
```

Output thật (JDK 21.0.10):

```text
{about=500, home=500}
[a, b, a!, b!]
consumed: 1 2 3 4 5
offer on full: false
{x=1} [1, 2, 3]
```
<!-- /EX -->

### 9. Atomic

<!-- EX:Ex09_Atomics -->
`examples/ch08/Ex09_Atomics.java`

```java
// objective: 8.2
// Lớp atomic: incrementAndGet vs getAndIncrement, compareAndSet, updateAndGet, accumulateAndGet.
import java.util.concurrent.atomic.*;

public class Ex09_Atomics {
    public static void main(String[] args) {
        AtomicInteger a = new AtomicInteger(5);
        System.out.println(a.getAndIncrement() + " " + a.get() + " " + a.incrementAndGet() + " " + a.get());
        System.out.println(a.compareAndSet(7, 100) + " " + a.get() + " " + a.compareAndSet(7, 200) + " " + a.get());
        System.out.println(a.updateAndGet(x -> x * 2) + " " + a.getAndUpdate(x -> x + 1) + " " + a.get());
        System.out.println(a.accumulateAndGet(10, Math::max) + " " + a.addAndGet(-1));

        AtomicLong big = new AtomicLong();
        big.addAndGet(5_000_000_000L);
        AtomicBoolean flag = new AtomicBoolean();
        System.out.println(big + " " + flag.getAndSet(true) + " " + flag.get());

        LongAdder adder = new LongAdder();                 // nhanh hơn khi nhiều thread cùng cộng
        adder.increment(); adder.add(10);
        AtomicReference<String> ref = new AtomicReference<>("v1");
        ref.set("v2");
        System.out.println(adder.sum() + " " + ref.get());
    }
}
```

Output thật (JDK 21.0.10):

```text
5 6 7 7
true 100 false 100
200 200 201
201 200
5000000000 false true
11 v2
```
<!-- /EX -->

### 10. CountDownLatch, CyclicBarrier

<!-- EX:Ex10_Coordination -->
`examples/ch08/Ex10_Coordination.java`

```java
// objective: 8.2
// Phối hợp thread: CountDownLatch (đợi N việc xong), CyclicBarrier (đợi nhau tại một điểm).
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Ex10_Coordination {
    public static void main(String[] args) throws Exception {
        CountDownLatch done = new CountDownLatch(3);
        AtomicInteger work = new AtomicInteger();
        for (int i = 0; i < 3; i++) {
            Thread.ofVirtual().start(() -> { work.addAndGet(10); done.countDown(); });
        }
        done.await();                                      // chặn cho tới khi count = 0
        System.out.println("latch released, work = " + work.get() + ", count = " + done.getCount());

        CyclicBarrier barrier = new CyclicBarrier(3, () -> System.out.println("barrier action: cả 3 đã tới"));
        try (ExecutorService ex = Executors.newFixedThreadPool(3)) {
            for (int i = 0; i < 3; i++) ex.submit(() -> { barrier.await(); return null; });
        }
        System.out.println("parties = " + barrier.getParties() + ", broken? " + barrier.isBroken());
    }
}
```

Output thật (JDK 21.0.10):

```text
latch released, work = 30, count = 0
barrier action: cả 3 đã tới
parties = 3, broken? false
```
<!-- /EX -->

### 11. Collection song song và parallel stream

<!-- EX:Ex11_ParallelCollections -->
`examples/ch08/Ex11_ParallelCollections.java`

```java
// objective: 8.3
// Xử lý collection song song: parallel stream, groupingByConcurrent, và bẫy tác dụng phụ (side effect).
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class Ex11_ParallelCollections {
    public static void main(String[] args) {
        List<Integer> nums = IntStream.rangeClosed(1, 10_000).boxed().toList();
        System.out.println("sum = " + nums.parallelStream().mapToLong(Integer::longValue).sum());

        List<Integer> good = nums.parallelStream().filter(n -> n % 1000 == 0).toList();   // giữ thứ tự gặp
        System.out.println("collected (ordered) = " + good);

        List<Integer> bad = new ArrayList<>();                 // KHÔNG an toàn khi ghi từ nhiều thread
        List<Integer> safe = Collections.synchronizedList(new ArrayList<>());
        nums.parallelStream().forEach(safe::add);
        System.out.println("synchronizedList size = " + safe.size() + " (thứ tự có thể lộn xộn)");

        ConcurrentMap<Boolean, Long> evenOdd = nums.parallelStream()
                .collect(Collectors.groupingByConcurrent(n -> n % 2 == 0, Collectors.counting()));
        System.out.println("groupingByConcurrent = " + new TreeMap<>(evenOdd));

        System.out.println("parallelism of common pool >= 1 ? " + (ForkJoinPool.commonPool().getParallelism() >= 1)
                + ", bad.size() = " + bad.size());
    }
}
```

Output thật (JDK 21.0.10):

```text
sum = 50005000
collected (ordered) = [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
synchronizedList size = 10000 (thứ tự có thể lộn xộn)
groupingByConcurrent = {false=5000, true=5000}
parallelism of common pool >= 1 ? true, bad.size() = 0
```
<!-- /EX -->

### 12. shutdownNow

<!-- EX:Ex12_ShutdownNow -->
`examples/ch08/Ex12_ShutdownNow.java`

```java
// objective: 8.1
// shutdown() vs shutdownNow(): shutdownNow interrupt các task đang chạy và trả về task chưa chạy.
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;

public class Ex12_ShutdownNow {
    public static void main(String[] args) throws Exception {
        ExecutorService single = Executors.newSingleThreadExecutor();
        CountDownLatch running = new CountDownLatch(1);
        AtomicBoolean interrupted = new AtomicBoolean();
        single.submit(() -> {
            running.countDown();
            try { Thread.sleep(10_000); } catch (InterruptedException e) {
                interrupted.set(true);                     // shutdownNow() đã interrupt task này
            }
        });
        for (int i = 0; i < 3; i++) single.submit(() -> System.out.println("never runs"));
        running.await();
        List<Runnable> notStarted = single.shutdownNow();
        System.out.println("chưa chạy: " + notStarted.size());
        System.out.println("terminated: " + single.awaitTermination(2, TimeUnit.SECONDS) + ", isTerminated: " + single.isTerminated());
        System.out.println("task đang chạy bị interrupt? " + interrupted.get());
    }
}
```

Output thật (JDK 21.0.10):

```text
chưa chạy: 3
terminated: true, isTerminated: true
task đang chạy bị interrupt? true
```
<!-- /EX -->

## Đi sâu

### Runnable vs Callable

| | `Runnable` | `Callable<V>` |
|---|---|---|
| Method | `void run()` | `V call() throws Exception` |
| Trả về | không | có |
| Checked exception | không được ném | được ném |
| Dùng với | `new Thread(r)`, `execute(r)`, `submit(r)` → `Future<?>` | `submit(c)` → `Future<V>`, `invokeAll`, `invokeAny` |

Lambda `() -> "x"` khớp `Callable`; `() -> System.out.println()` khớp cả hai (compiler chọn tuỳ ngữ cảnh);
`() -> { return; }` chỉ khớp `Runnable`.

### Vòng đời thread (`Thread.State`)

`NEW` (tạo, chưa start) → `RUNNABLE` (đang chạy hoặc sẵn sàng) → có thể vào `BLOCKED` (chờ khoá `synchronized`),
`WAITING` (`join()`, `wait()`, `LockSupport.park`), `TIMED_WAITING` (`sleep(ms)`, `join(ms)`) → `TERMINATED`.

- `start()` hai lần → `IllegalThreadStateException`. Gọi `run()` trực tiếp không tạo thread.
- `interrupt()` đánh thức thread đang `sleep`/`wait`/`join` bằng `InterruptedException`; nếu thread đang chạy thì chỉ
  đặt cờ (`isInterrupted()`).
- JVM kết thúc khi mọi thread **không phải daemon** đã kết thúc.

### ExecutorService

| Tạo | Ghi chú |
|---|---|
| `Executors.newSingleThreadExecutor()` | Một thread, task chạy tuần tự theo thứ tự gửi |
| `Executors.newFixedThreadPool(n)` | n thread |
| `Executors.newCachedThreadPool()` | Tạo thêm khi cần, dùng lại thread rảnh |
| `Executors.newScheduledThreadPool(n)` / `newSingleThreadScheduledExecutor()` | `schedule`, `scheduleAtFixedRate`, `scheduleWithFixedDelay` |
| `Executors.newVirtualThreadPerTaskExecutor()` | Một virtual thread mới cho mỗi task |

| Method | Ý nghĩa |
|---|---|
| `execute(Runnable)` | `void`, từ `Executor` |
| `submit(Runnable/Callable)` | `Future` |
| `invokeAll(tasks)` | Đợi tất cả; `List<Future>` theo thứ tự task |
| `invokeAny(tasks)` | Đợi một task thành công; trả về **kết quả** trực tiếp, huỷ các task còn lại |
| `shutdown()` | Không nhận task mới; task cũ chạy nốt. Gửi thêm → `RejectedExecutionException` |
| `shutdownNow()` | Interrupt task đang chạy, trả về `List<Runnable>` chưa chạy |
| `awaitTermination(t, unit)` | Đợi tối đa t; trả về `true` nếu đã kết thúc |
| `isShutdown()`, `isTerminated()` | |
| `close()` (Java 19+) | `ExecutorService` là `AutoCloseable`: shutdown + đợi → dùng được với try-with-resources |

`Future`: `get()` (chặn; lỗi trong task → `ExecutionException` với `getCause()`), `get(t, unit)` (→ `TimeoutException`),
`isDone()`, `cancel(mayInterrupt)`, `isCancelled()`.

### Thread-safety

- **Race condition**: `count++` = đọc, cộng, ghi — không nguyên tử (atomic).
- `synchronized` method (khoá `this`, hoặc `Class` nếu static) / khối `synchronized (obj)` (obj phải là tham chiếu).
  Constructor không `synchronized` được.
- `Lock` / `ReentrantLock`: `lock()` + `unlock()` trong `finally`; `tryLock()` / `tryLock(t, unit)` trả về `boolean`;
  reentrant (hold count); `unlock()` khi không giữ → `IllegalMonitorStateException`. `ReentrantReadWriteLock`:
  nhiều reader hoặc một writer.
- Atomic: `AtomicInteger`, `AtomicLong`, `AtomicBoolean`, `AtomicReference`: `get`, `set`, `getAndIncrement`
  (trả cũ) / `incrementAndGet` (trả mới), `compareAndSet`, `updateAndGet`, `accumulateAndGet`. `LongAdder` cho bộ đếm
  nhiều thread.
- Phối hợp: `CountDownLatch` (đếm ngược một lần, không âm), `CyclicBarrier` (đợi nhau, dùng lại được).
- Vấn đề liveness: **deadlock** (hai thread giữ khoá và chờ khoá của nhau), **starvation** (một thread không bao giờ
  được chạy), **livelock** (hai thread liên tục nhường nhau, không tiến triển).

### Concurrent collections

| Lớp | Ghi chú |
|---|---|
| `ConcurrentHashMap` | Không nhận key/value `null`; `merge`, `compute`, `putIfAbsent` nguyên tử |
| `CopyOnWriteArrayList` / `CopyOnWriteArraySet` | Ghi = sao chép mảng; iterator duyệt snapshot, không CME |
| `ConcurrentLinkedQueue`, `ConcurrentSkipListMap/Set` | Không khoá / có sắp xếp |
| `ArrayBlockingQueue`, `LinkedBlockingQueue` | `put`/`take` chặn; `offer`/`poll` không chặn (hoặc có timeout) |
| `Collections.synchronizedList/Map(...)` | Bọc đồng bộ từng method; duyệt vẫn phải tự `synchronized` |

### Parallel stream (8.3)

- Chạy trên `ForkJoinPool.commonPool()`. Chỉ có lợi với dữ liệu lớn, việc nặng CPU, không tác dụng phụ.
- Ghi vào collection thường từ `forEach` song song là lỗi; hãy dùng `collect`, `toList()`, `groupingByConcurrent`,
  `toConcurrentMap`, hoặc collection đồng bộ.
- `forEach` không giữ thứ tự; `forEachOrdered` giữ thứ tự gặp. `findAny` có thể trả phần tử bất kỳ.
- `reduce` cần identity đúng + hàm kết hợp (xem chương 6).

## Lỗi và bẫy thường gặp (Exam traps)

1. `t.run()` không tạo thread; `start()` hai lần → exception.
2. Lambda `Runnable` gọi `Thread.sleep` mà không bắt `InterruptedException` → lỗi biên dịch; `Callable` thì được.
3. `execute` trả về `void`; `submit(Runnable)` trả `Future<?>` với `get()` = `null`.
4. Exception trong task → `ExecutionException` khi `get()`.
5. `invokeAll` giữ thứ tự task; `invokeAny` trả kết quả, không trả `Future`.
6. Sau `shutdown()` gửi task → `RejectedExecutionException`; task đang chạy vẫn tiếp tục.
7. `synchronized (primitive)` và constructor `synchronized` → lỗi biên dịch.
8. `unlock()` không giữ khoá → `IllegalMonitorStateException`; quên `unlock()` → thread khác chờ mãi.
9. `getAndIncrement` vs `incrementAndGet`.
10. `ConcurrentHashMap.put(null, …)` → NPE.
11. `offer` không chặn (trả `false`), `put` chặn.
12. Virtual thread luôn daemon; `setDaemon(false)` → `IllegalArgumentException`.
13. `forEach` trên parallel stream không có thứ tự.

## Góc nhìn từ TypeScript

| TypeScript / Node.js | Java | Ghi chú |
|---|---|---|
| Một thread chạy event loop; `async/await` không chạy song song code JS | Nhiều thread thật, dùng chung bộ nhớ | Race condition là chuyện có thật trong Java |
| `Promise<T>` | `Future<T>` / `CompletableFuture<T>` | `future.get()` **chặn** thread; `await` thì không chặn event loop |
| `Promise.all([...])` | `invokeAll(tasks)` | |
| `Promise.any([...])` | `invokeAny(tasks)` | |
| Worker threads (không chung bộ nhớ, trừ `SharedArrayBuffer`) | Thread chung heap | Cần `synchronized`, `Lock`, atomic |
| `Atomics.add` trên `SharedArrayBuffer` | `AtomicInteger.addAndGet` | |
| async I/O không chặn | Virtual thread: viết code chặn bình thường, JVM tự "nhả" carrier thread khi chờ | Code đơn giản như code đồng bộ |

## Tóm tắt

- Tạo thread: `extends Thread`, `new Thread(Runnable)`, `Thread.ofPlatform()/ofVirtual()`, `startVirtualThread`.
- Vòng đời: NEW → RUNNABLE → BLOCKED/WAITING/TIMED_WAITING → TERMINATED.
- ExecutorService: `submit`/`execute`/`invokeAll`/`invokeAny`, `shutdown`/`shutdownNow`/`awaitTermination`, `close()`.
- Thread-safe: `synchronized`, `ReentrantLock` (unlock trong finally), atomic, concurrent collections.
- Parallel stream: không side effect, dùng collector; `forEachOrdered` để giữ thứ tự.

## Bài tập (có lời giải)

Mọi đáp án đã được `tools/book.py` biên dịch và chạy để xác nhận (code: `examples/questions/ch08/`). Các câu hỏi được
thiết kế để có output xác định; bộ kiểm tra đã được chạy lặp lại nhiều lần với cùng kết quả.

### Câu hỏi

<!-- QUESTIONS:ch08 -->
#### Câu 08-01 · Dễ · objective 8.1

Chương trình sau in ra gì?

```java
public class RunStart {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> System.out.print(Thread.currentThread().getName() + " "), "worker");
        t.run();
        t.start();
        t.join();
    }
}
```

- **A.** `main worker`
- **B.** `worker worker`
- **C.** `main main`
- **D.** `worker main`

#### Câu 08-02 · Vừa · objective 8.1

Chương trình sau in ra gì?

```java
import java.util.concurrent.*;

public class Fail {
    public static void main(String[] args) {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        Future<Integer> f = ex.submit(() -> Integer.parseInt("x1"));
        try {
            System.out.println(f.get());
        } catch (ExecutionException e) {
            System.out.println("EE:" + e.getCause().getClass().getSimpleName());
        } catch (InterruptedException e) {
            System.out.println("IE");
        } finally {
            ex.shutdown();
        }
    }
}
```

- **A.** Ném `NumberFormatException` ra khỏi `main`
- **B.** `EE:ExecutionException`
- **C.** `null`
- **D.** `EE:NumberFormatException`

#### Câu 08-03 · Vừa · objective 8.1

Những dòng nào gây lỗi biên dịch?

```java
import java.util.concurrent.*;

public class Tasks {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(1);
        Future<?> a = ex.submit(() -> System.out.println("a"));        // L1
        Future<String> b = ex.submit(() -> "b");                       // L2
        Callable<Void> c = () -> { Thread.sleep(10); return null; };   // L3
        Runnable d = () -> { Thread.sleep(10); };                      // L4
        Future<Integer> e = ex.submit(() -> { return; });              // L5
        ex.shutdown();
    }
}
```

- **A.** Chỉ L4
- **B.** L4 và L5
- **C.** L3 và L4
- **D.** L3, L4 và L5
- **E.** Chỉ L5

#### Câu 08-04 · Vừa · objective 8.1

Chương trình sau in ra gì?

```java
public class States {
    public static void main(String[] args) throws InterruptedException {
        Thread t = new Thread(() -> { });
        System.out.print(t.getState() + " ");
        t.start();
        t.join();
        System.out.print(t.getState() + " " + t.isAlive());
    }
}
```

- **A.** `NEW RUNNABLE true`
- **B.** `CREATED TERMINATED false`
- **C.** `NEW TERMINATED false`
- **D.** `NEW DEAD false`

#### Câu 08-05 · Vừa · objective 8.1

Hai phát biểu nào đúng về virtual thread (Java 21)? **(Chọn 2 đáp án.)**

- **A.** Virtual thread luôn là daemon thread.
- **B.** `Thread.ofVirtual().start(r)` trả về một thread đã được start.
- **C.** `new Thread(r)` tạo ra một virtual thread.
- **D.** Có thể gọi `setDaemon(false)` trên virtual thread.
- **E.** `Executors.newVirtualThreadPerTaskExecutor()` giới hạn số thread chạy cùng lúc bằng số CPU.

#### Câu 08-06 · Vừa · objective 8.1

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.concurrent.*;

public class AllOf {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(3);
        List<Callable<Integer>> tasks = List.of(
                () -> { Thread.sleep(200); return 1; },
                () -> 2,
                () -> { Thread.sleep(100); return 3; });
        StringBuilder sb = new StringBuilder();
        for (Future<Integer> f : ex.invokeAll(tasks)) sb.append(f.get());
        ex.shutdown();
        System.out.println(sb);
    }
}
```

- **A.** `213`
- **B.** `231`
- **C.** `123`
- **D.** Thứ tự không xác định

#### Câu 08-07 · Khó · objective 8.2

Chương trình sau in ra gì?

```java
import java.util.concurrent.atomic.AtomicInteger;

public class Atom {
    public static void main(String[] args) {
        AtomicInteger a = new AtomicInteger(10);
        int x = a.getAndAdd(5);
        int y = a.incrementAndGet();
        boolean z = a.compareAndSet(15, 0);
        int w = a.updateAndGet(v -> v * 2);
        System.out.println(x + " " + y + " " + z + " " + w);
    }
}
```

- **A.** `15 16 true 0`
- **B.** `10 16 true 0`
- **C.** `15 17 false 34`
- **D.** `10 16 false 32`

#### Câu 08-08 · Vừa · objective 8.2

Những dòng nào gây lỗi biên dịch?

```java
public class Sync {
    private final Object lock = new Object();
    private int count;

    synchronized void a() { count++; }                        // L1
    void b() { synchronized (lock) { count++; } }             // L2
    void c() { synchronized (count) { count++; } }            // L3
    static synchronized void d() { }                          // L4
    synchronized Sync() { }                                   // L5

    public static void main(String[] args) { }
}
```

- **A.** Chỉ L3
- **B.** L3 và L5
- **C.** L4 và L5
- **D.** L1 và L3
- **E.** Chỉ L5

#### Câu 08-09 · Vừa · objective 8.2

Chương trình sau in ra gì?

```java
import java.util.concurrent.locks.ReentrantLock;

public class Holds {
    public static void main(String[] args) {
        ReentrantLock lock = new ReentrantLock();
        lock.lock();
        lock.lock();
        System.out.print(lock.getHoldCount() + " ");
        lock.unlock();
        System.out.print(lock.isLocked() + " ");
        lock.unlock();
        System.out.print(lock.isLocked() + " ");
        try {
            lock.unlock();
        } catch (IllegalMonitorStateException e) {
            System.out.print("IMSE");
        }
    }
}
```

- **A.** `2 true false IMSE`
- **B.** `2 false false IMSE`
- **C.** `1 true false IMSE`
- **D.** `2 true false`

#### Câu 08-10 · Khó · objective 8.2

Hai phát biểu nào đúng? **(Chọn 2 đáp án.)**

- **A.** `ConcurrentHashMap` không cho phép key `null`.
- **B.** `CopyOnWriteArrayList` cho phép thêm phần tử trong lúc đang duyệt bằng for-each mà không ném `ConcurrentModificationException`.
- **C.** Gọi `unlock()` trên `ReentrantLock` mà thread không giữ thì không có gì xảy ra.
- **D.** `AtomicInteger.getAndIncrement()` trả về giá trị sau khi tăng.
- **E.** `ArrayBlockingQueue.offer(e)` chặn (block) khi hàng đợi đầy.

#### Câu 08-11 · Vừa · objective 8.3

Điều gì đúng về kết quả của chương trình?

```java
import java.util.*;

public class Ordered {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        List.of(1, 2, 3, 4, 5).parallelStream()
                .map(x -> x * x)
                .forEachOrdered(x -> sb.append(x).append(','));
        System.out.println(sb);
    }
}
```

- **A.** Luôn in `1,4,9,16,25,`
- **B.** In các số theo thứ tự bất kỳ
- **C.** Ném `ConcurrentModificationException`
- **D.** Không biên dịch được vì `sb` được sửa trong lambda

#### Câu 08-12 · Vừa · objective 8.2

Chương trình sau in ra gì?

```java
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
```

- **A.** `-1`
- **B.** Ném `IllegalStateException`
- **C.** Chương trình bị treo (chờ mãi ở `await()`)
- **D.** `0`

#### Câu 08-13 · Vừa · objective 8.1

Những dòng nào gây lỗi biên dịch?

```java
import java.util.concurrent.*;

public class Exec {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newCachedThreadPool();
        ex.execute(() -> System.out.println("x"));               // L1
        Future<?> f = ex.execute(() -> System.out.println("y"));  // L2
        Future<String> g = ex.submit(() -> "z");                  // L3
        ex.execute(() -> "w");                                    // L4
        ex.shutdown();
    }
}
```

- **A.** Chỉ L2
- **B.** Chỉ L4
- **C.** L2 và L4
- **D.** L3 và L4
- **E.** L1 và L2

#### Câu 08-14 · Vừa · objective 8.1

Chương trình sau in ra gì?

```java
import java.util.concurrent.*;

public class Shut {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newSingleThreadExecutor();
        ex.submit(() -> System.out.print("A ")).get();
        ex.shutdown();
        try {
            ex.submit(() -> System.out.print("B "));
        } catch (RejectedExecutionException e) {
            System.out.print("R ");
        }
        ex.awaitTermination(1, TimeUnit.SECONDS);
        System.out.print(ex.isTerminated());
    }
}
```

- **A.** `A B true`
- **B.** `A R true`
- **C.** `A R false`
- **D.** `R A true`

#### Câu 08-15 · Khó · objective 8.1

Chèn dòng nào vào chỗ `// INSERT CODE HERE` thì chương trình biên dịch và in ra `4`? **(Chọn 3 đáp án.)**

```java
import java.util.*;
import java.util.concurrent.*;

public class Wait {
    public static void main(String[] args) throws Exception {
        ExecutorService ex = Executors.newFixedThreadPool(2);
        Callable<Integer> task = () -> 2 + 2;
        // INSERT CODE HERE
        ex.shutdown();
    }
}
```

- **A.** `System.out.println(ex.submit(task).get());`
- **B.** `System.out.println(ex.submit(task));`
- **C.** `System.out.println(ex.invokeAll(List.of(task)).get(0).get());`
- **D.** `System.out.println(ex.invokeAny(List.of(task)));`
- **E.** `ex.execute(task);`

#### Câu 08-16 · Vừa · objective 8.2, 8.3

Chương trình sau in ra gì?

```java
import java.util.*;
import java.util.concurrent.*;

public class Cow {
    public static void main(String[] args) {
        List<Integer> list = new CopyOnWriteArrayList<>(List.of(1, 2, 3));
        int count = 0;
        for (Integer i : list) {
            list.add(i * 10);
            count++;
        }
        System.out.println(count + " " + list.size());
    }
}
```

- **A.** `6 6`
- **B.** Ném `ConcurrentModificationException`
- **C.** `3 6`
- **D.** Vòng lặp chạy mãi

#### Câu 08-17 · Khó · objective 8.3, 6.2

Điền thao tác nào vào **cả hai** chỗ `___` thì kết quả tuần tự và song song giống nhau (in ra `same`)? **(Chọn 3 đáp án.)**

```java
import java.util.stream.*;

public class Assoc {
    public static void main(String[] args) {
        int seq = IntStream.rangeClosed(1, 5).___;
        int par = IntStream.rangeClosed(1, 5).parallel().___;
        System.out.println(seq == par ? "same" : "different");
    }
}
```

- **A.** `reduce(0, Integer::sum)`
- **B.** `reduce(1, (a, b) -> a * b)`
- **C.** `reduce(0, (a, b) -> a - b)`
- **D.** `reduce(5, Integer::sum)`
- **E.** `reduce(Integer.MIN_VALUE, Integer::max)`

#### Câu 08-18 · Vừa · objective 8.1

Chương trình sau in ra gì?

```java
public class Builders {
    public static void main(String[] args) {
        Thread v = Thread.ofVirtual().name("v-", 1).unstarted(() -> { });
        Thread p = Thread.ofPlatform().name("p").unstarted(() -> { });
        System.out.println(v.getName() + " " + v.isVirtual() + " " + p.isVirtual() + " " + v.getState());
    }
}
```

- **A.** `v- true false NEW`
- **B.** `v-1 true false NEW`
- **C.** `v-1 true false RUNNABLE`
- **D.** `v-1 false false NEW`

#### Câu 08-19 · Dễ · objective 8.1

Chương trình sau in ra gì?

```java
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
```

- **A.** `ATB`
- **B.** `TAB`
- **C.** `AB`
- **D.** Thứ tự không xác định

#### Câu 08-20 · Vừa · objective 8.2

Chương trình sau in ra gì?

```java
import java.util.concurrent.*;

public class Queue {
    public static void main(String[] args) {
        BlockingQueue<String> q = new ArrayBlockingQueue<>(2);
        System.out.print(q.offer("a") + " " + q.offer("b") + " " + q.offer("c") + " ");
        System.out.print(q.poll() + " " + q.peek() + " " + q.size());
    }
}
```

- **A.** `true true true a b 2`
- **B.** `true true false a a 1`
- **C.** `true true false b b 1`
- **D.** `true true false a b 1`
<!-- /QUESTIONS -->

### Lời giải

<!-- ANSWERS:ch08 -->
#### Câu 08-01 — Đáp án: **A**

- **Vì sao đúng:** `run()` chỉ là một lời gọi method bình thường, chạy trên thread hiện tại (`main`). `start()` mới tạo thread mới và thread đó gọi `run()` → tên `worker`. `join()` đợi thread `worker` in xong.
- **B sai:** `t.run()` không tạo thread mới; nó chạy trên `main`.
- **C sai:** `t.start()` chạy lambda trên thread mới tên `worker`.
- **D sai:** `t.run()` được gọi trước và chạy đồng bộ trên `main`.
- *Kiểm chứng:* `examples/questions/ch08/Q08_01/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-02 — Đáp án: **D**

- **Vì sao đúng:** Exception xảy ra **bên trong task** không bay thẳng ra thread gọi. `Future.get()` gói nó vào `ExecutionException`; exception gốc lấy bằng `getCause()`.
- **A sai:** Exception trong task được gói lại, `main` nhận `ExecutionException`.
- **B sai:** `getCause()` trả về exception gốc (`NumberFormatException`), không phải chính `ExecutionException`.
- **C sai:** Task thất bại nên `get()` ném exception, không trả về `null`.
- *Kiểm chứng:* `examples/questions/ch08/Q08_02/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-03 — Đáp án: **B**

- **Vì sao đúng:** `Runnable.run()` không khai báo `throws`, nên lambda Runnable không được ném checked exception như `InterruptedException` của `Thread.sleep` (L4). Lambda `() -> { return; }` không trả giá trị nên chỉ khớp `Runnable`; `submit(Runnable)` trả về `Future<?>`, không gán được cho `Future<Integer>` (L5).
- **A sai:** L5 cũng lỗi: lambda không trả giá trị → `submit(Runnable)` → `Future<?>`.
- **C sai:** `Callable.call()` khai báo `throws Exception`, nên L3 được phép gọi `Thread.sleep`.
- **D sai:** L3 hợp lệ (xem C).
- **E sai:** L4 cũng lỗi vì checked exception trong Runnable.
- *Kiểm chứng:* `examples/questions/ch08/Q08_03/` — compile error confirmed at ['L4', 'L5'] (`python3 tools/book.py questions ch08`).

#### Câu 08-04 — Đáp án: **C**

- **Vì sao đúng:** Thread vừa tạo (chưa `start()`) ở trạng thái `NEW`. Sau `join()`, thread chắc chắn đã chạy xong → `TERMINATED` và `isAlive()` là `false`.
- **A sai:** `join()` đợi thread kết thúc, nên không còn `RUNNABLE`.
- **B sai:** Không có trạng thái `CREATED` trong `Thread.State`; trạng thái đầu là `NEW`.
- **D sai:** Không có trạng thái `DEAD`; trạng thái cuối là `TERMINATED`.
- *Kiểm chứng:* `examples/questions/ch08/Q08_04/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-05 — Đáp án: **A, B**

- **Vì sao đúng:** A: virtual thread luôn là daemon (JVM không đợi chúng khi thoát). B: `start(...)` của `Thread.Builder` tạo và start thread luôn (khác `unstarted(...)`).
- **C sai:** Constructor `Thread` tạo **platform thread**; virtual thread tạo qua `Thread.ofVirtual()`, `Thread.startVirtualThread` hoặc executor.
- **D sai:** Đổi virtual thread thành non-daemon → `IllegalArgumentException`.
- **E sai:** Executor này tạo **một virtual thread mới cho mỗi task**, không giới hạn theo số CPU (ví dụ: 200 task cùng chờ nhau vẫn chạy xong).
- *Kiểm chứng:* `examples/questions/ch08/Q08_05/` — each option proven true/false by a program (`python3 tools/book.py questions ch08`).

#### Câu 08-06 — Đáp án: **C**

- **Vì sao đúng:** `invokeAll` đợi **tất cả** task xong và trả về list `Future` theo **đúng thứ tự của list task**, không theo thứ tự hoàn thành.
- **A sai:** Đây là thứ tự hoàn thành; `invokeAll` giữ thứ tự của danh sách đầu vào.
- **B sai:** Như A — thứ tự kết quả là thứ tự task.
- **D sai:** Thứ tự list kết quả được bảo đảm khớp với list task.
- *Kiểm chứng:* `examples/questions/ch08/Q08_06/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-07 — Đáp án: **D**

- **Vì sao đúng:** `getAndAdd(5)` trả về giá trị **cũ** (10), a = 15. `incrementAndGet()` trả về giá trị **mới** (16). `compareAndSet(15, 0)` thất bại vì giá trị hiện tại là 16 → `false`, không đổi. `updateAndGet(v * 2)` → 32.
- **A sai:** `getAndXxx` trả về giá trị trước khi đổi; và compareAndSet thất bại vì a đang là 16.
- **B sai:** compareAndSet chỉ thành công khi giá trị hiện tại **bằng đúng** giá trị mong đợi (15), mà a là 16.
- **C sai:** `getAndAdd` trả về 10 (giá trị cũ), và `incrementAndGet` chỉ tăng một lần.
- *Kiểm chứng:* `examples/questions/ch08/Q08_07/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-08 — Đáp án: **B**

- **Vì sao đúng:** Khối `synchronized (x)` cần `x` là **tham chiếu object**; `count` là `int` → L3 lỗi. Constructor không được khai báo `synchronized` → L5 lỗi. Method instance và static đều có thể `synchronized` (khoá trên `this` hoặc trên `Sync.class`).
- **A sai:** L5 cũng lỗi: constructor không dùng được `synchronized`.
- **C sai:** `static synchronized` hợp lệ (khoá trên object `Class`).
- **D sai:** Method `synchronized` (L1) hợp lệ.
- **E sai:** L3 cũng lỗi vì primitive không làm khoá được.
- *Kiểm chứng:* `examples/questions/ch08/Q08_08/` — compile error confirmed at ['L3', 'L5'] (`python3 tools/book.py questions ch08`).

#### Câu 08-09 — Đáp án: **A**

- **Vì sao đúng:** `ReentrantLock` cho phép cùng một thread `lock()` nhiều lần; mỗi lần tăng hold count. Phải `unlock()` đúng số lần mới thật sự mở khoá. `unlock()` khi không giữ khoá → `IllegalMonitorStateException`.
- **B sai:** Sau lần `unlock()` đầu, hold count còn 1 nên khoá vẫn đang bị giữ.
- **C sai:** Khoá được lấy hai lần nên hold count là 2.
- **D sai:** `unlock()` thêm lần nữa khi không giữ khoá sẽ ném exception.
- *Kiểm chứng:* `examples/questions/ch08/Q08_09/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-10 — Đáp án: **A, B**

- **Vì sao đúng:** A: `ConcurrentHashMap` cấm cả key lẫn value `null`. B: `CopyOnWriteArrayList` tạo bản sao mảng mỗi lần ghi; iterator duyệt ảnh chụp cũ nên không ném exception.
- **C sai:** `unlock()` khi không giữ khoá ném `IllegalMonitorStateException`.
- **D sai:** `getAndIncrement()` trả về giá trị **cũ** (5); `incrementAndGet()` mới trả về giá trị mới.
- **E sai:** `offer` trả về `false` ngay khi đầy; `put` mới là method chặn.
- *Kiểm chứng:* `examples/questions/ch08/Q08_10/` — each option proven true/false by a program (`python3 tools/book.py questions ch08`).

#### Câu 08-11 — Đáp án: **A**

- **Vì sao đúng:** `forEachOrdered` xử lý phần tử theo **thứ tự gặp (encounter order)** của nguồn có thứ tự (`List`), kể cả khi stream song song, và không gọi action đồng thời. Vì vậy output luôn giống nhau.
- **B sai:** Đó là hành vi của `forEach` trên parallel stream.
- **C sai:** Không có collection nào bị sửa khi đang duyệt.
- **D sai:** `sb` là effectively final (không bị gán lại); gọi method trên object là được phép.
- *Kiểm chứng:* `examples/questions/ch08/Q08_11/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-12 — Đáp án: **D**

- **Vì sao đúng:** `countDown()` khi count đã về 0 thì không làm gì (không âm). `await()` trả về ngay khi count là 0.
- **A sai:** Count không bao giờ âm.
- **B sai:** Gọi `countDown()` thừa không ném exception.
- **C sai:** Count đã về 0 nên `await()` không chờ.
- *Kiểm chứng:* `examples/questions/ch08/Q08_12/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-13 — Đáp án: **C**

- **Vì sao đúng:** `execute(Runnable)` (của `Executor`) trả về `void` → không gán cho `Future` được (L2). `execute` chỉ nhận `Runnable`; lambda `() -> "w"` trả về giá trị và `"w"` không phải một câu lệnh hợp lệ cho `void` → không khớp `Runnable` (L4). `submit` có bản nhận `Callable` nên L3 hợp lệ.
- **A sai:** L4 cũng lỗi: `execute` không nhận `Callable`.
- **B sai:** L2 cũng lỗi: `execute` trả về `void`.
- **D sai:** `submit(Callable<String>)` trả về `Future<String>` → L3 hợp lệ.
- **E sai:** L1 hợp lệ: `execute` nhận `Runnable`.
- *Kiểm chứng:* `examples/questions/ch08/Q08_13/` — compile error confirmed at ['L2', 'L4'] (`python3 tools/book.py questions ch08`).

#### Câu 08-14 — Đáp án: **B**

- **Vì sao đúng:** Task đầu chạy xong (`get()` đợi). Sau `shutdown()`, executor **từ chối** task mới → `RejectedExecutionException`. Không còn task nào nên `awaitTermination` kết thúc và `isTerminated()` là `true`.
- **A sai:** Sau `shutdown()`, không nhận task mới.
- **C sai:** Không còn task đang chạy, nên executor kết thúc (terminated) ngay.
- **D sai:** `get()` đợi task đầu in `A ` trước khi `main` tiếp tục.
- *Kiểm chứng:* `examples/questions/ch08/Q08_14/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-15 — Đáp án: **A, C, D**

- **Vì sao đúng:** A: `submit` trả về `Future`, `get()` đợi và lấy kết quả. C: `invokeAll` trả về list `Future`. D: `invokeAny` trả về **trực tiếp** kết quả của một task hoàn thành thành công.
- **B sai:** In ra `toString()` của `Future` (dạng `java.util.concurrent.FutureTask@...`), không phải 4.
- **E sai:** `execute` chỉ nhận `Runnable`, không nhận `Callable` → lỗi biên dịch.
- *Kiểm chứng:* `examples/questions/ch08/Q08_15/` — variants: ACD satisfy output (`python3 tools/book.py questions ch08`).

#### Câu 08-16 — Đáp án: **C**

- **Vì sao đúng:** Iterator của `CopyOnWriteArrayList` duyệt **ảnh chụp** tại lúc tạo iterator (3 phần tử). Các phần tử thêm sau không được duyệt, nhưng vẫn nằm trong list → size 6.
- **A sai:** Vòng lặp chỉ thấy 3 phần tử của ảnh chụp ban đầu.
- **B sai:** `CopyOnWriteArrayList` không ném exception này.
- **D sai:** Phần tử mới không được đưa vào vòng lặp đang chạy, nên vòng lặp kết thúc.
- *Kiểm chứng:* `examples/questions/ch08/Q08_16/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-17 — Đáp án: **A, B, E**

- **Vì sao đúng:** `reduce` song song đúng khi identity là phần tử trung hoà thật và hàm có tính **kết hợp (associative)**. Cộng với 0, nhân với 1, `max` với `Integer.MIN_VALUE` đều thoả.
- **C sai:** Phép trừ không kết hợp: (a - b) - c ≠ a - (b - c). Kết quả song song phụ thuộc cách chia (trên máy kiểm tra: khác tuần tự).
- **D sai:** 5 không phải identity của phép cộng; mỗi phần nhỏ đều cộng thêm 5 nên kết quả song song lớn hơn.
- *Kiểm chứng:* `examples/questions/ch08/Q08_17/` — variants: ABE satisfy output (`python3 tools/book.py questions ch08`).

#### Câu 08-18 — Đáp án: **B**

- **Vì sao đúng:** `name(prefix, start)` đặt tên = prefix + số đếm (bắt đầu từ `start`) → `v-1`. `unstarted` tạo thread nhưng chưa chạy → `NEW`. `ofVirtual` tạo virtual thread, `ofPlatform` tạo platform thread.
- **A sai:** `name("v-", 1)` nối thêm số đếm vào tên.
- **C sai:** `unstarted` không start thread.
- **D sai:** `Thread.ofVirtual()` tạo virtual thread → `isVirtual()` là `true`.
- *Kiểm chứng:* `examples/questions/ch08/Q08_18/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-19 — Đáp án: **A**

- **Vì sao đúng:** `A` được thêm trước khi start thread. `join()` làm `main` đợi thread `t` kết thúc (và bảo đảm thấy được thay đổi của nó), rồi mới thêm `B`. Vì vậy luôn là `ATB`.
- **B sai:** Thread `t` chỉ bắt đầu sau khi `A` đã được thêm.
- **C sai:** `join()` đợi thread `t` chạy xong, nên `T` chắc chắn đã được thêm.
- **D sai:** `start()` sau `A` và `join()` trước `B` làm thứ tự được xác định.
- *Kiểm chứng:* `examples/questions/ch08/Q08_19/` — output confirmed (`python3 tools/book.py questions ch08`).

#### Câu 08-20 — Đáp án: **D**

- **Vì sao đúng:** Sức chứa là 2: `offer("c")` trả về `false` (không chặn). `poll()` lấy và xoá phần tử đầu (`a`). `peek()` chỉ xem phần tử đầu mới (`b`). Còn lại 1 phần tử.
- **A sai:** Hàng đợi đầy sau 2 phần tử nên `offer("c")` thất bại.
- **B sai:** `poll()` đã xoá `a`, nên `peek()` thấy `b`.
- **C sai:** Queue là FIFO: `poll()` lấy `a` (vào trước).
- *Kiểm chứng:* `examples/questions/ch08/Q08_20/` — output confirmed (`python3 tools/book.py questions ch08`).
<!-- /ANSWERS -->

## Đọc thêm (link chính thức — bị chặn trong sandbox nên mình chưa mở được)

- JEP 444 Virtual Threads: https://openjdk.org/jeps/444
- Javadoc gói `java.util.concurrent`: https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/package-summary.html
- JLS Chương 17 Threads and Locks: https://docs.oracle.com/javase/specs/jls/se21/html/jls-17.html

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- `Thread.java` (virtual thread luôn daemon, `Thread.Builder`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/lang/Thread.java
- `ExecutorService.java` (`close()`, `shutdownNow`, `invokeAny`): https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/concurrent/ExecutorService.java
- `ReentrantLock.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/concurrent/locks/ReentrantLock.java
- `CountDownLatch.java`: https://raw.githubusercontent.com/openjdk/jdk21u/master/src/java.base/share/classes/java/util/concurrent/CountDownLatch.java

// Same problem in Java 21.
import java.util.*;
import java.util.concurrent.*;

public class Compare {
    record User(int id, String name, int age, String email) {}

    static final List<User> users = List.of(
        new User(1, "An", 28, "an@example.com"),
        new User(2, "Bình", 17, null),
        new User(3, "Chi", 35, "chi@example.com"));

    static CompletableFuture<String> findNameAsync(int id) {
        return CompletableFuture.supplyAsync(() -> {
            try { Thread.sleep(10); } catch (InterruptedException e) { throw new RuntimeException(e); }
            return users.stream().filter(u -> u.id() == id).findFirst()
                .orElseThrow(() -> new NoSuchElementException("User " + id + " không tồn tại"))
                .name();
        });
    }

    public static void main(String[] args) {
        // 1. Stream filter + map
        var adults = users.stream().filter(u -> u.age() >= 18).map(u -> u.name().toUpperCase()).toList();
        System.out.println("Người lớn: " + String.join(", ", adults));

        // 2. Null: Optional (Java has no ?. operator)
        for (var u : users)
            System.out.println(u.name() + ": " + Optional.ofNullable(u.email()).map(e -> String.valueOf(e.length())).orElse("không có email"));

        // 3. Record: value equality, but no `with` (make a new one)
        var first = users.get(0);
        var older = new User(first.id(), first.name(), 29, first.email());
        var same = new User(1, "An", 28, "an@example.com");
        System.out.println(older);
        System.out.println("users[0].equals(bản sao cùng dữ liệu)? " + first.equals(same));

        // 4. async (CompletableFuture) - join() blocks here
        System.out.println("Tìm thấy: " + findNameAsync(3).join());

        // 5. Exception
        try {
            findNameAsync(99).join();
        } catch (CompletionException ex) {
            System.out.println("Lỗi: " + ex.getCause().getMessage());
        }
    }
}

// objective: 6.1
// Stream "lười" (lazy): không có terminal operation thì không chạy gì; phần tử đi qua pipeline TỪNG CÁI MỘT.
import java.util.List;
import java.util.stream.Stream;

public class Ex03_Laziness {
    public static void main(String[] args) {
        Stream<String> s = Stream.of("a", "bb", "ccc")
                .peek(x -> System.out.println("peek " + x))
                .filter(x -> x.length() > 1);
        System.out.println("chưa có terminal → chưa in peek");
        System.out.println(s.toList());

        List<String> result = Stream.of("one", "two", "three", "four")
                .filter(x -> { System.out.println("filter " + x); return x.length() == 3; })
                .map(x -> { System.out.println("map " + x); return x.toUpperCase(); })
                .limit(1)                                    // đủ 1 phần tử thì dừng luôn
                .toList();
        System.out.println(result);

        Stream<Integer> once = Stream.of(1, 2);
        once.count();
        try {
            once.count();                                     // stream chỉ dùng được một lần
        } catch (IllegalStateException e) {
            System.out.println("IllegalStateException: " + e.getMessage());
        }
    }
}

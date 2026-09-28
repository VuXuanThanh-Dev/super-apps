// objective: 6.2, 8.3
// Parallel stream: kết quả reduce đúng chỉ khi identity đúng nghĩa và hàm có tính kết hợp (associative).
import java.util.List;
import java.util.stream.IntStream;

public class Ex11_ParallelReduce {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4);
        System.out.println("seq sum      = " + nums.stream().reduce(0, Integer::sum));
        System.out.println("par sum      = " + nums.parallelStream().reduce(0, Integer::sum));
        System.out.println("seq reduce10 = " + nums.stream().reduce(10, Integer::sum));
        // 10 không phải identity của phép cộng → song song cộng 10 ở MỖI phần nhỏ (kết quả phụ thuộc cách chia)
        System.out.println("par reduce10 = " + nums.parallelStream().reduce(10, Integer::sum));
        // Phép trừ không kết hợp → song song cho kết quả khác tuần tự
        System.out.println("seq minus    = " + IntStream.rangeClosed(1, 4).reduce(0, (a, b) -> a - b));
        System.out.println("par minus    = " + IntStream.rangeClosed(1, 4).parallel().reduce(0, (a, b) -> a - b));
        System.out.println("isParallel   = " + nums.parallelStream().isParallel() + " / "
                + nums.stream().parallel().sequential().isParallel());
        // forEachOrdered giữ thứ tự nguồn kể cả khi song song
        StringBuilder sb = new StringBuilder();
        nums.parallelStream().map(x -> x * 10).forEachOrdered(x -> sb.append(x).append(' '));
        System.out.println("forEachOrdered: " + sb.toString().trim());
        System.out.println("findFirst trên parallel vẫn là phần tử đầu: " + nums.parallelStream().findFirst().get());
    }
}

import java.util.stream.*;

public class Powers {
    public static void main(String[] args) {
        String s = IntStream.iterate(1, i -> i * 3).takeWhile(i -> i < 100)
                .mapToObj(Integer::toString).collect(Collectors.joining(","));
        System.out.println(s + " " + IntStream.of(4, 8, 2).map(i -> i / 2).max().getAsInt());
    }
}

import java.util.*;

public class Empty {
    public static void main(String[] args) {
        List<String> empty = List.of();
        System.out.println(empty.stream().count() + " "
                + empty.stream().allMatch(s -> s.length() > 5) + " "
                + empty.stream().anyMatch(s -> true));
    }
}

import java.util.*;

public class Sorts {
    public static void main(String[] args) {
        List<String> words = List.of("apple", "fig", "kiwi", "banana");
        System.out.println(words.stream().sorted(Comparator.comparingInt(String::length)).toList());
    }
}

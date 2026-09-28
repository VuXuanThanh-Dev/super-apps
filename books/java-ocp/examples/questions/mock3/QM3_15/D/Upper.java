import java.util.*;
import java.util.stream.*;

public class Upper {
    public static void main(String[] args) {
        List<String> in = List.of("a,b", "c");
        System.out.println(String.join(",", in).toUpperCase().chars().filter(Character::isLetter).mapToObj(c -> String.valueOf((char) c)).toList());
    }
}

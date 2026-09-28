import java.util.Optional;

public class Opt {
    public static void main(String[] args) {
        Optional<String> o = Optional.of("  ");
        String r = o.map(String::strip).filter(s -> !s.isEmpty()).map(String::toUpperCase).orElseGet(() -> "EMPTY");
        System.out.println(r + " " + Optional.ofNullable(null).isPresent() + " "
                + Optional.of("x").or(() -> Optional.of("y")).get());
    }
}

import java.util.function.*;

public class Compose {
    public static void main(String[] args) {
        Function<Integer, Integer> inc = x -> x + 1;
        Function<Integer, Integer> dbl = x -> x * 2;
        System.out.println(inc.andThen(dbl).apply(3) + " " + inc.compose(dbl).apply(3) + " "
                + dbl.andThen(dbl).compose(inc).apply(1));
    }
}

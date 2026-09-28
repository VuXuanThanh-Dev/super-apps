// objective: 2.1, 3.5
// expect: compile-error
// Thứ tự case trong pattern switch: case rộng hơn đứng trước sẽ "che" (dominate) case hẹp hơn.
public class Ex13_Dominance {
    static String f(Object o) {
        return switch (o) {
            case Number num -> "number";
            case Integer i -> "integer";     // không bao giờ tới được
            default -> "other";
        };
    }

    public static void main(String[] args) {
        System.out.println(f(1));
    }
}

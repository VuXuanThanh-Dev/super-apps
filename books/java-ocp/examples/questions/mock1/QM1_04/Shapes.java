public class Shapes {
    sealed interface Shape permits Circle, Rect { }
    record Circle(double r) implements Shape { }
    record Rect(double w, double h) implements Shape { }

    static String kind(Shape s) {
        return switch (s) {
            case Circle c when c.r() > 10 -> "big circle";
            case Circle c -> "circle";
            case Rect(double w, double h) when w == h -> "square";
            case Rect r -> "rect";
        };
    }

    public static void main(String[] args) {
        System.out.println(kind(new Circle(5)) + ", " + kind(new Rect(2, 2)) + ", "
                + kind(new Circle(11)) + ", " + kind(new Rect(1, 3)));
    }
}

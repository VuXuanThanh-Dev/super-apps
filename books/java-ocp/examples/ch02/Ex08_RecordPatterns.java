// objective: 2.1, 3.5
// Record pattern (Java 21): "mở" record ngay trong instanceof và switch, kể cả lồng nhau.
public class Ex08_RecordPatterns {
    record Point(int x, int y) {}
    record Line(Point from, Point to) {}

    sealed interface Shape permits Circle, Square {}
    record Circle(double r) implements Shape {}
    record Square(double side) implements Shape {}

    static double area(Shape s) {
        return switch (s) {                  // sealed + record: đủ các trường hợp, không cần default
            case Circle(double r) -> Math.PI * r * r;
            case Square(var side) -> side * side;
        };
    }

    public static void main(String[] args) {
        Object o = new Line(new Point(0, 0), new Point(3, 4));
        if (o instanceof Line(Point(var x1, var y1), Point(int x2, int y2))) {
            System.out.println("length = " + Math.hypot(x2 - x1, y2 - y1));
        }
        System.out.printf("%.2f %.2f%n", area(new Circle(1)), area(new Square(3)));

        Object p = new Point(5, 0);
        String where = switch (p) {
            case Point(int x, int y) when y == 0 -> "trên trục X tại " + x;
            case Point(int x, int y) -> "điểm " + x + "," + y;
            default -> "không phải Point";
        };
        System.out.println(where);
    }
}

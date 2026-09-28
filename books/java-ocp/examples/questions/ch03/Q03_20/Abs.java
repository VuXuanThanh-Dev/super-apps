public class Abs {
    abstract static class Shape {
        abstract double area();                    // L1
        abstract void draw() { }                   // L2
        Shape() { }                                // L3
    }

    static class Sq extends Shape {                // L4
        double area() { return 1; }
    }

    public static void main(String[] args) {
        Shape s = new Sq();
    }
}

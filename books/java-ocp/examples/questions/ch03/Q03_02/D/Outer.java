public class Outer {
    class Inner { }
    static class Nested { }

    public static void main(String[] args) {
        Outer.Nested n = new Outer().new Nested();
    }
}

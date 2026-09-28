public class Outer {
    class Inner { }
    static class Nested { }

    public static void main(String[] args) {
        Nested n = new Outer.Nested();
    }
}

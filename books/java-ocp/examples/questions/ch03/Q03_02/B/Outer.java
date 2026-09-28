public class Outer {
    class Inner { }
    static class Nested { }

    public static void main(String[] args) {
        Outer.Inner i = new Outer().new Inner();
    }
}

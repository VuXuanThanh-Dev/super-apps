public class Wins {
    interface Named {
        String name();
        default String greet() { return prefix() + name(); }
        private String prefix() { return "Hi "; }
    }

    static class Base { public String greet() { return "Base greet"; } }

    static class Person extends Base implements Named { public String name() { return "An"; } }

    static class Robot implements Named {
        public String name() { return "R2"; }
        public String greet() { return Named.super.greet() + "!"; }
    }

    public static void main(String[] args) {
        System.out.println(new Person().greet() + " | " + new Robot().greet());
    }
}

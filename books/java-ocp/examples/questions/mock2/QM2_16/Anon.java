public class Anon {
    interface Greeter { String greet(); }

    String name = "outer";

    Greeter make() {
        String name = "local";
        return new Greeter() {
            String name = "anon";
            public String greet() { return name + "," + this.name + "," + Anon.this.name; }
        };
    }

    public static void main(String[] args) {
        System.out.println(new Anon().make().greet());
    }
}

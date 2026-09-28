class Animal {
    Animal self() { return this; }
    static String type() { return "animal"; }
    String name() { return "a"; }
}

class Cat extends Animal {
    @Override Cat self() { return this; }
    static String type() { return "cat"; }
    @Override String name() { return "c" + super.name(); }
}

public class Covariant {
    public static void main(String[] args) {
        Animal a = new Cat();
        System.out.println(a.self().name() + " " + a.self().getClass().getSimpleName() + " "
                + a.type() + " " + ((Cat) a).type());
    }
}

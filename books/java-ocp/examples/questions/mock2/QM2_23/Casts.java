public class Casts {
    interface Swimmer { }
    static class Fish implements Swimmer { }
    static class Dog { }

    public static void main(String[] args) {
        Fish f = new Fish();
        Swimmer s1 = f;
        Dog d = null;
        Swimmer s2 = (Swimmer) d;
        System.out.print((s2 == null) + " ");
        Swimmer s3 = (Swimmer) new Dog();
        System.out.print("done");
    }
}

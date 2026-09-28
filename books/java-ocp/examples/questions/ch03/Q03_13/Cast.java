public class Cast {
    static class Animal { }
    static class Cat extends Animal { }
    static class Dog extends Animal { }

    public static void main(String[] args) {
        Animal a = new Cat();
        Object o = a;
        System.out.print((o instanceof Animal) + " ");
        Dog d = (Dog) a;
        System.out.println("done");
    }
}

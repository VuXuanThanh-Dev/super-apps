// objective: 3.5
// Override vs hiding: method instance chọn theo KIỂU OBJECT (lúc chạy);
// field và method static chọn theo KIỂU THAM CHIẾU (lúc biên dịch).
class Animal {
    String name = "animal";
    static String kind() { return "Animal.kind"; }
    String sound() { return "..."; }
    String describe() { return name + " says " + sound(); }   // sound() là lời gọi đa hình
}

class Dog extends Animal {
    String name = "dog";                            // che (hide) field của cha
    static String kind() { return "Dog.kind"; }     // che method static (không phải override)
    @Override String sound() { return "Woof"; }
    String fetch() { return "fetching"; }
}

public class Ex08_Polymorphism {
    public static void main(String[] args) {
        Animal a = new Dog();                       // kiểu tham chiếu Animal, kiểu object Dog
        System.out.println(a.sound());              // Woof  (override → theo object)
        System.out.println(a.name);                 // animal (field → theo tham chiếu)
        System.out.println(a.kind());               // Animal.kind (static → theo tham chiếu)
        System.out.println(a.describe());           // "animal says Woof"
        // a.fetch();                               // lỗi: Animal không có fetch()
        System.out.println(((Dog) a).fetch() + " " + ((Dog) a).name);
    }
}

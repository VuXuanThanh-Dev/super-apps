class A {
    A() { print(); }
    void print() { System.out.print("A "); }
}

class B extends A {
    int x = 5;
    B() { print(); }
    @Override void print() { System.out.print("B" + x + " "); }
}

public class Ctor {
    public static void main(String[] args) {
        new B();
    }
}

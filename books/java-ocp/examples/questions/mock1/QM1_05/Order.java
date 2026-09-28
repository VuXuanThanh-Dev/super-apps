public class Order {
    static int s = print("s1");
    int i = print("i1");
    static { print("sb"); }
    { print("ib"); }
    Order() { print("c"); }

    static int print(String t) {
        System.out.print(t + " ");
        return 0;
    }

    public static void main(String[] args) {
        print("main");
        new Order();
        new Order();
    }
}

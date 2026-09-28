public class Pat {
    static void m(Object o) {
        boolean b = o instanceof Integer i && i > 0; System.out.print(i);
    }

    public static void main(String[] args) { m("x"); }
}

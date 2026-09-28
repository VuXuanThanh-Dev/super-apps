public class Pat {
    static void m(Object o) {
        if (o instanceof String s) { } System.out.print(s);
    }

    public static void main(String[] args) { m("x"); }
}

public class Pat {
    static void m(Object o) {
        if (!(o instanceof String s)) return; System.out.print(s.length());
    }

    public static void main(String[] args) { m("x"); }
}

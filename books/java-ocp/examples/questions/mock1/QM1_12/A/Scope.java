public class Scope {
    int field = 1;

    void m() {
        var list = java.util.List.of(1, 2); for (var i : list) System.out.print(i);
    }

    public static void main(String[] args) { }
}

public class Scope {
    int field = 1;

    void m() {
        final var y = 3; int z = y * 2;
    }

    public static void main(String[] args) { }
}

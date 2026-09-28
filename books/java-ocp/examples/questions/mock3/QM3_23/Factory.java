public class Factory {
    private static int created = 0;

    static class Part { Part() { created++; } }

    class Tool { Part p = new Part(); }

    public static void main(String[] args) {
        Factory f = new Factory();
        Tool t1 = f.new Tool();
        Tool t2 = f.new Tool();
        Part extra = new Part();
        t1 = t2;
        System.out.println(created + " " + (t1.p == t2.p));
    }
}

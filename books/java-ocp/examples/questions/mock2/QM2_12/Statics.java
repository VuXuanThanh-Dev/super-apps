public class Statics {
    interface Tool {
        static String id() { return "tool"; }
        default String name() { return id(); }
    }

    static class Hammer implements Tool { }

    public static void main(String[] args) {
        Hammer h = new Hammer();
        String a = Tool.id();          // L1
        String b = h.name();           // L2
        String c = Hammer.id();        // L3
        String d = h.id();             // L4
    }
}

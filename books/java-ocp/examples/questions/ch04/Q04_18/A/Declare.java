public class Declare {
    static class BadValue extends Exception { BadValue(String m) { super(m); } }

    static void check(int v) throws BadValue {
        if (v < 0) throw new BadValue("negative");
    }

    public static void main(String[] args) throws Throwable {
        check(1);
        System.out.println("ok");
    }
}

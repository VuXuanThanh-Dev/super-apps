public class Flow {
    static String f(Object o) {
        if (!(o instanceof Integer n) || n < 0) return "no";
        return "int " + (n + 1);
    }

    public static void main(String[] args) {
        System.out.println(f(5) + " | " + f(-1) + " | " + f("x"));
    }
}

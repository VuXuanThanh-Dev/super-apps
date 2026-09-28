public class Swallow {
    @SuppressWarnings("finally")
    static String f() {
        try {
            throw new RuntimeException("A");
        } catch (RuntimeException e) {
            throw new IllegalStateException("B");
        } finally {
            return "C";
        }
    }

    public static void main(String[] args) {
        try {
            System.out.println(f());
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}

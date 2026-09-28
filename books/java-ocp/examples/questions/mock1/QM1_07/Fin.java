public class Fin {
    static String test(int n) {
        StringBuilder sb = new StringBuilder();
        try {
            sb.append("t");
            if (n == 0) throw new IllegalStateException();
            sb.append("u");
            return sb.append("r").toString();
        } catch (IllegalStateException e) {
            sb.append("c");
            return sb.toString();
        } finally {
            sb.append("f");
        }
    }

    public static void main(String[] args) {
        System.out.println(test(1) + " " + test(0));
    }
}

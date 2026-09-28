public class Nested {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        try {
            try {
                sb.append("1");
                throw new IllegalStateException("x");
            } catch (IllegalArgumentException e) {
                sb.append("2");
            } finally {
                sb.append("3");
            }
            sb.append("4");
        } catch (RuntimeException e) {
            sb.append("5");
        } finally {
            sb.append("6");
        }
        System.out.println(sb);
    }
}

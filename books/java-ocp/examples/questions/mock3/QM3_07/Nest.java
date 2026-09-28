public class Nest {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        try {
            try {
                sb.append(1);
                throw new Exception("e1");
            } catch (Exception e) {
                sb.append(2);
                throw new RuntimeException("e2", e);
            } finally {
                sb.append(3);
            }
        } catch (RuntimeException e) {
            sb.append(4).append(e.getCause().getMessage());
        } finally {
            sb.append(5);
        }
        System.out.println(sb);
    }
}

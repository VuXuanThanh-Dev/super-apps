// objective: 4.1
// Suppressed exception: lỗi khi close() được "đính kèm" vào exception chính.
// So sánh với finally ném exception: exception gốc bị MẤT.
public class Ex05_Suppressed {
    static class Bad implements AutoCloseable {
        @Override public void close() throws Exception { throw new Exception("close failed"); }
    }

    public static void main(String[] args) {
        try (Bad b = new Bad()) {
            throw new RuntimeException("body failed");
        } catch (Exception e) {
            System.out.println("primary: " + e.getMessage());
            for (Throwable s : e.getSuppressed()) System.out.println("suppressed: " + s.getMessage());
        }

        try {
            try {
                throw new RuntimeException("try failed");
            } finally {
                throw new IllegalStateException("finally failed");   // thay thế exception gốc
            }
        } catch (RuntimeException e) {
            System.out.println("caught: " + e.getMessage() + ", suppressed=" + e.getSuppressed().length);
        }
    }
}

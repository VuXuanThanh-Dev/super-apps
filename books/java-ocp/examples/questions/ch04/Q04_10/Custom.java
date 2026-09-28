public class Custom {
    static class AppException extends Exception {
        AppException(String m) { super(m); }
    }

    public static void main(String[] args) {
        try {
            throw new AppException("oops");
        } catch (AppException e) {
            System.out.println(e.getMessage() + " | " + e);
        }
    }
}

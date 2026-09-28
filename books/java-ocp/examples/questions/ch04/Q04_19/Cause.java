public class Cause {
    public static void main(String[] args) {
        try {
            try {
                Object o = null;
                o.toString();
            } catch (NullPointerException e) {
                throw new IllegalStateException("wrapped", e);
            }
        } catch (IllegalStateException e) {
            System.out.println(e.getMessage() + " / " + (e.getCause() instanceof NullPointerException));
        }
    }
}

// objective: 4.1
// Exception trong khối static → ExceptionInInitializerError (một Error), lần sau → NoClassDefFoundError.
public class Ex10_InitializerError {
    static class Config {
        static int value = Integer.parseInt("not a number");
    }

    public static void main(String[] args) {
        for (int i = 0; i < 2; i++) {
            try {
                System.out.println(Config.value);
            } catch (Throwable t) {
                System.out.println(t.getClass().getSimpleName()
                        + (t.getCause() != null ? " caused by " + t.getCause().getClass().getSimpleName() : ""));
            }
        }
    }
}

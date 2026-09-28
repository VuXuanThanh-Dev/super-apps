public class Chain {
    static class AppEx extends Exception {
        AppEx(String m, Throwable c) { super(m, c); }
    }

    static void load() throws AppEx {
        try {
            Integer.parseInt("x");
        } catch (NumberFormatException e) {
            throw new AppEx("load failed", e);
        } finally {
            System.out.print("F ");
        }
    }

    public static void main(String[] args) {
        try {
            load();
        } catch (AppEx e) {
            System.out.print(e.getMessage() + " <- " + e.getCause().getClass().getSimpleName());
        }
    }
}

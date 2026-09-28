public class Boot {
    static class Cfg {
        static final int N = compute();
        static int compute() {
            System.out.print("compute ");
            return 1 / 0;
        }
    }

    public static void main(String[] args) {
        try {
            System.out.print(Cfg.N);
        } catch (ExceptionInInitializerError e) {
            System.out.print("EIIE:" + e.getCause().getClass().getSimpleName());
        }
    }
}

public class Init {
    static String log = "";
    static { log += "S"; }
    { log += "I"; }
    Init() { log += "C"; }
    Init(int x) { this(); log += "X"; }

    public static void main(String[] args) {
        new Init(1);
        new Init();
        System.out.println(log);
    }
}

public class DefaultFirst {
    static String f(int n) {
        String r = "";
        switch (n) {
            default: r += "d";
            case 1: r += "1";
            case 2: r += "2"; break;
            case 3: r += "3";
        }
        return r;
    }

    public static void main(String[] args) {
        System.out.println(f(1) + " " + f(3) + " " + f(9));
    }
}

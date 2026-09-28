public class Fall {
    public static void main(String[] args) {
        int x = 2;
        String r = "";
        switch (x) {
            case 1: r += "a";
            case 2: r += "b";
            case 3: r += "c"; break;
            default: r += "d";
        }
        System.out.println(r);
    }
}

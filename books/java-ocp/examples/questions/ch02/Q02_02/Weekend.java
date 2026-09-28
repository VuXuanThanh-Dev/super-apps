public class Weekend {
    public static void main(String[] args) {
        String day = "SAT";
        int n = switch (day) {
            case "MON", "TUE" -> 1;
            case "SAT" -> {
                int k = 5;
                yield k * 2;
            }
            default -> 0;
        };
        System.out.println(n);
    }
}

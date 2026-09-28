public class Yield {
    public static void main(String[] args) {
        int v = 3;
        String a = switch (v) { case 1 -> "one"; default -> "other"; };                // L1
        String b = switch (v) { case 1: yield "one"; default: yield "other"; };        // L2
        String c = switch (v) { case 1 -> { yield "one"; } default -> "other"; };      // L3
        String d = switch (v) { case 1 -> "one"; case 2 -> "two"; };                   // L4
    }
}

public class Sw {
    enum Level { LOW, MID, HIGH }

    static int a(Level l) { return switch (l) { case LOW -> 1; case MID -> 2; case HIGH -> 3; }; }   // L1
    static int b(Level l) { return switch (l) { case LOW -> 1; case MID -> 2; }; }                   // L2
    static int c(String s) { return switch (s) { case "a": yield 1; default: yield 0; }; }          // L3
    static int d(int n) { return switch (n) { case 1 -> 1; case 1 -> 2; default -> 0; }; }          // L4
    static int e(Object o) { return switch (o) { case String t -> 1; default -> 0; }; }             // L5

    public static void main(String[] args) { }
}

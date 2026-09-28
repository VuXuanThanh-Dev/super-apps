public class Blocks {
    public static void main(String[] args) {
        int x = 1;
        { int y = 2; x += y; }
        for (int i = 0; i < 2; i++) { int z = i; }
        int y = 3;                                     // L1
        int z = 4;                                     // L2
        for (int x2 = 0, y2 = 1; x2 < 1; x2++) { }     // L3
        int i = x;                                     // L4
        { int x = 5; }                                 // L5
    }
}

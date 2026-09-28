public class Reach {
    public static void main(String[] args) {
        int x = 0;
        while (x < 3) x++;                      // L1
        for (;;) { if (x > 5) break; x++; }     // L2
        do x--; while (x > 0);                   // L3
        while (false) { x++; }                   // L4
        System.out.println(x);
    }
}

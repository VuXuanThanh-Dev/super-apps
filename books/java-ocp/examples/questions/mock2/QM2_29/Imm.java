public class Imm {
    static final class Money {
        private final long cents;
        private final String cur;

        Money(long cents, String cur) { this.cents = cents; this.cur = cur; }
        Money add(long c) { cents += c; return this; }                // L1
        Money plus(long c) { return new Money(cents + c, cur); }      // L2
        void rename(String c) { this.cur = c; }                       // L3
        String cur() { return cur; }                                  // L4
    }

    public static void main(String[] args) { }
}

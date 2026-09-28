public class Members {
    interface Shape {
        int SIDES = 0;                         // L1
        private void log() { }                 // L2
        protected double area();               // L3
        static Shape unit() { return null; }   // L4
        default void print() { log(); }        // L5
    }

    public static void main(String[] args) { }
}

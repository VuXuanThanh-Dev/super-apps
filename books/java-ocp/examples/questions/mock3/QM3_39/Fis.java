public class Fis {
    @FunctionalInterface interface A { void run(); }                                     // L1
    @FunctionalInterface interface B { void run(); void stop(); }                        // L2
    @FunctionalInterface interface C extends A { }                                       // L3
    @FunctionalInterface interface D extends A { default void stop() { } }               // L4
    @FunctionalInterface interface E { boolean equals(Object o); }                       // L5

    public static void main(String[] args) { }
}

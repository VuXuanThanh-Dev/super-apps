public class Hier {
    sealed interface Vehicle permits Car, Bike, Truck { }
    record Car(int seats) implements Vehicle { }                // L1
    static final class Bike implements Vehicle { }             // L2
    static non-sealed class Truck implements Vehicle { }        // L3
    static class BigTruck extends Truck { }                     // L4
    record Boat() extends Car { }                               // L5
    static class Scooter extends Bike { }                       // L6

    public static void main(String[] args) { }
}

// objective: 3.5
// Lớp abstract và sealed: permits, final / sealed / non-sealed ở lớp con.
public class Ex09_AbstractSealed {
    static abstract sealed class Vehicle permits Car, Truck, Bike {
        abstract int wheels();
        String info() { return getClass().getSimpleName() + " has " + wheels() + " wheels"; }
    }
    static final class Car extends Vehicle { int wheels() { return 4; } }
    static sealed class Truck extends Vehicle permits BigTruck { int wheels() { return 6; } }
    static final class BigTruck extends Truck { @Override int wheels() { return 18; } }
    static non-sealed class Bike extends Vehicle { int wheels() { return 2; } }
    static class EBike extends Bike { }                 // non-sealed mở lại cho mọi lớp con

    static String tax(Vehicle v) {
        return switch (v) {                              // sealed → switch đầy đủ không cần default
            case Car c -> "low";
            case Truck t -> "high";
            case Bike b -> "none";
        };
    }

    public static void main(String[] args) {
        Vehicle[] all = {new Car(), new Truck(), new BigTruck(), new Bike(), new EBike()};
        for (Vehicle v : all) System.out.println(v.info() + " / tax " + tax(v));
        // new Vehicle();   // lỗi: abstract
        System.out.println(Vehicle.class.isSealed() + " " + java.util.Arrays.toString(
                java.util.Arrays.stream(Vehicle.class.getPermittedSubclasses()).map(Class::getSimpleName).toArray()));
    }
}

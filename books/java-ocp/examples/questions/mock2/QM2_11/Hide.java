class P {
    String name = "P";
    String who() { return "P.who:" + name; }
}

class C extends P {
    String name = "C";
    String who() { return "C.who:" + name + "/" + super.name + "/" + super.who(); }
}

public class Hide {
    public static void main(String[] args) {
        P p = new C();
        System.out.println(p.who() + " | " + p.name);
    }
}

public class GenericPattern {
    record Box<T>(T value) { }

    public static void main(String[] args) {
        Object o = new Box<>("hi");
        String r;
        if (o instanceof Box<?>(String s) && s.length() == 2) r = "string box " + s;
        else if (o instanceof Box<?> b) r = "box " + b.value();
        else r = "other";
        System.out.println(r);
    }
}

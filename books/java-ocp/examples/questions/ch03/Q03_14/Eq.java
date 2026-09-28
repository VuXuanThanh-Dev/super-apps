import java.util.*;

public class Eq {
    static class Id {
        final int v;
        Id(int v) { this.v = v; }
        public boolean equals(Id o) { return o != null && o.v == v; }
        @Override public int hashCode() { return v; }
    }

    public static void main(String[] args) {
        Id a = new Id(1), b = new Id(1);
        Object ob = b;
        List<Id> list = new ArrayList<>(List.of(a));
        System.out.println(a.equals(b) + " " + a.equals(ob) + " " + list.contains(b));
    }
}

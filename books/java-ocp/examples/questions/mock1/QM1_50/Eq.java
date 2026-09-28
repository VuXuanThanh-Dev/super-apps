import java.util.*;

public class Eq {
    record Pt(int x, int y) { }

    static class Pix {
        int x;
        Pix(int x) { this.x = x; }
        @Override public boolean equals(Object o) { return o instanceof Pix p && p.x == x; }
    }

    public static void main(String[] args) {
        Set<Object> set = new HashSet<>();
        set.add(new Pt(1, 2));
        set.add(new Pt(1, 2));
        set.add(new Pix(5));
        set.add(new Pix(5));
        System.out.println(set.size() + " " + new Pix(5).equals(new Pix(5)) + " " + new Pt(1, 2).equals(new Pt(1, 2)));
    }
}

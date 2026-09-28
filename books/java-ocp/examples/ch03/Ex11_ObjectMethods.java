// objective: 3.5
// Override equals/hashCode/toString của Object; ảnh hưởng tới HashSet.
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class Ex11_ObjectMethods {
    static class NoOverride { int id; NoOverride(int id) { this.id = id; } }

    static class User {
        final int id;
        User(int id) { this.id = id; }
        @Override public boolean equals(Object o) {
            return o instanceof User u && u.id == id;
        }
        @Override public int hashCode() { return Objects.hash(id); }
        @Override public String toString() { return "User#" + id; }
    }

    static class BadEquals {
        int id;
        BadEquals(int id) { this.id = id; }
        public boolean equals(BadEquals o) { return o.id == id; }   // OVERLOAD, không phải override!
    }

    public static void main(String[] args) {
        Set<Object> set = new HashSet<>();
        set.add(new NoOverride(1)); set.add(new NoOverride(1));
        set.add(new User(1)); set.add(new User(1));
        System.out.println("size=" + set.size());
        System.out.println(new User(7) + " " + new User(7).equals(new User(7)));
        Object x = new BadEquals(1);
        System.out.println(new BadEquals(1).equals(new BadEquals(1)) + " " + x.equals(new BadEquals(1)));
        String s = new NoOverride(3).toString();
        System.out.println(s.startsWith("Ex11_ObjectMethods$NoOverride@"));
    }
}

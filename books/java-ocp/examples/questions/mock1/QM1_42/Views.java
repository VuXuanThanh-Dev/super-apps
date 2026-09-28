import java.util.*;

public class Views {
    public static void main(String[] args) {
        final List<String> names = new ArrayList<>(List.of("a"));
        List<String> view = Collections.unmodifiableList(names);
        names.add("b");
        record Team(List<String> members) {
            Team { members = List.copyOf(members); }
        }
        Team t = new Team(names);
        names.add("c");
        System.out.println(view.size() + " " + t.members().size() + " " + names.size());
    }
}

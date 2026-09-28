import java.util.Arrays;

public class Tags {
    record Tag(String[] values) {
        Tag { values = values.clone(); }
        static Tag of(String... v) { return new Tag(v); }
    }

    public static void main(String[] args) {
        String[] src = {"a", "b"};
        Tag t1 = Tag.of(src), t2 = Tag.of(src);
        src[0] = "z";
        System.out.println(t1.values()[0] + " " + t1.equals(t2) + " " + Arrays.equals(t1.values(), t2.values()));
    }
}

public class Block {
    public static void main(String[] args) {
        String t = """
            ab\tc
              d\
            e
            """;
        System.out.println(t.lines().count() + " " + t.length() + " "
                + t.indent(2).lines().findFirst().get().length() + " " + "  x ".strip().length());
    }
}

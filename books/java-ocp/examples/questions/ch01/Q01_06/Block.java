public class Block {
    public static void main(String[] args) {
        String tb = """
            A\s
              B \
            C
            """;
        System.out.print(tb.replace(' ', '.').replace("\n", "|"));
    }
}

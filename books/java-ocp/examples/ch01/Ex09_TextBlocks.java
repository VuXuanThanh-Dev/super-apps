// objective: 1.3
// Text block: thụt lề (incidental whitespace), \s, \ nối dòng, dấu " bên trong.
public class Ex09_TextBlocks {
    public static void main(String[] args) {
        String json = """
            {
              "name": "Nobin",
              "lang": "Java"
            }
            """;
        System.out.print(json);
        System.out.println("ends with newline? " + json.endsWith("\n"));

        String noNewline = """
            one line \
            continued""";
        System.out.println("[" + noNewline + "]");

        String keepSpace = """
            a  \s
            b""";
        System.out.println(keepSpace.replace(' ', '.'));

        String closingLeft = """
                indented
            """;                      // dấu """ đóng lệch trái → giữ 4 dấu cách
        System.out.print(closingLeft.replace(' ', '.'));

        String quotes = """
            She said "hi" and \""" is fine""";
        System.out.println(quotes);
        System.out.println(json.lines().count() + " lines");
    }
}

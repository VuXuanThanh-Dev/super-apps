public class Strings {
    public static void main(String[] args) {
        String s = "Java";
        switch (s.toLowerCase()) {
            case "JAVA" -> System.out.print("A");
            case "java" -> System.out.print("B");
            default -> System.out.print("C");
        }
        switch (s) {
            case "java": System.out.print("D");
            default: System.out.print("E");
            case "Java": System.out.print("F");
        }
    }
}

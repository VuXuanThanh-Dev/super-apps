public class Str {
    public static void main(String[] args) {
        String s = "Hello, World";
        System.out.println(s.indexOf('o') + " " + s.lastIndexOf("o") + " " + s.substring(7).toUpperCase() + " "
                + s.replace('l', 'L').charAt(3) + " " + s.contains("world"));
    }
}

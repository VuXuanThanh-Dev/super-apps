public class Sb2 {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.setCharAt(0, 'A');
        sb.replace(1, 3, "-");
        sb.deleteCharAt(sb.length() - 1).append(sb.length());
        System.out.println(sb + " " + "ab".compareTo("abc") + " " + "b".compareTo("a") + " "
                + String.valueOf(new char[]{'h', 'i'}).repeat(2));
    }
}

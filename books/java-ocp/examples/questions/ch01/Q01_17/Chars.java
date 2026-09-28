public class Chars {
    public static void main(String[] args) {
        char c = 'A';
        c += 2;
        int i = c + 1;
        c++;
        System.out.println(c + " " + i + " " + (char) i + (c + 1));
    }
}

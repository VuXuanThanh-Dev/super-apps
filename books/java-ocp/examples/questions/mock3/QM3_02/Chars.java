public class Chars {
    public static void main(String[] args) {
        char c = 'x';
        int i = c;
        System.out.println(i + " " + Character.isLetter(c) + " " + Character.getNumericValue('7') + " "
                + Integer.toBinaryString(5) + " " + Integer.parseInt("-0012"));
    }
}

public class Boxes {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Long c = 127L;
        System.out.println((a == b) + " " + a.equals(c) + " " + (a.intValue() == c) + " " + c.equals(127L));
    }
}

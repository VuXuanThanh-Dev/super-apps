public class Pool {
    public static void main(String[] args) {
        String a = "hello";
        String b = "hel";
        System.out.println(a == (b + "lo").intern());
    }
}

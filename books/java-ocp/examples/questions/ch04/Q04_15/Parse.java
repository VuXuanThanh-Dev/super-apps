public class Parse {
    public static void main(String[] args) {
        try {
            int n = Integer.parseInt("3.5");
            System.out.println(n);
        } catch (IllegalArgumentException e) {
            System.out.println("IAE");
        } catch (RuntimeException e) {
            System.out.println("RE");
        }
    }
}

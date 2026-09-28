package m.user;
public class Main {
    public static void main(String[] a) throws Exception {
        var f = m.model.S.class.getDeclaredField("x");
        try { f.setAccessible(true); System.out.println("accessible"); }
        catch (RuntimeException e) { System.out.println(e.getClass().getSimpleName()); }
    }
}

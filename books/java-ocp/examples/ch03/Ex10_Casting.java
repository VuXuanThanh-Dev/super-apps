// objective: 3.5
// Ép kiểu tham chiếu: upcast tự động, downcast cần cast và có thể ném ClassCastException.
public class Ex10_Casting {
    interface Swimmer {}
    static class Fish implements Swimmer {}
    static class Shark extends Fish {}
    static final class Rock {}

    public static void main(String[] args) {
        Fish f = new Shark();                 // upcast: không cần cast
        Shark s = (Shark) f;                  // downcast: OK vì object thật là Shark
        Object o = new Fish();
        System.out.println((o instanceof Shark) + " " + (o instanceof Swimmer) + " " + (null instanceof Object));
        try {
            Shark bad = (Shark) o;            // biên dịch được, nhưng lúc chạy object là Fish
        } catch (ClassCastException e) {
            System.out.println("ClassCastException");
        }
        Swimmer sw = (Swimmer) new Object[]{f}[0];   // cast sang interface: compiler thường cho phép
        System.out.println(sw.getClass().getSimpleName());
        // Rock r = (Rock) f;                 // lỗi biên dịch: Fish và Rock không liên quan
        // Swimmer x = (Swimmer) new Rock();  // lỗi biên dịch: Rock là final và không implements Swimmer
        if (f instanceof Shark sh && sh != null) System.out.println("pattern: " + sh.getClass().getSimpleName());
    }
}

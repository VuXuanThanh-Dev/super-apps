package m.user;
import java.lang.reflect.Field;
public class Main {
    public static void main(String[] args) throws Exception {
        Field f = m.model.Config.class.getDeclaredField("env");
        f.setAccessible(true);
        System.out.println("env=" + f.get(new m.model.Config()));
    }
}

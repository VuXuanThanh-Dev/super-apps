// objective: 4.1
// Cây kế thừa của exception: checked (phải khai báo/bắt) vs unchecked (RuntimeException, Error).
import java.io.FileNotFoundException;
import java.io.IOException;

public class Ex01_Hierarchy {
    static void chain(Class<?> c) {
        StringBuilder sb = new StringBuilder(c.getSimpleName());
        for (Class<?> p = c.getSuperclass(); p != null; p = p.getSuperclass()) sb.append(" -> ").append(p.getSimpleName());
        boolean unchecked = RuntimeException.class.isAssignableFrom(c) || Error.class.isAssignableFrom(c);
        System.out.println(sb + (unchecked ? "   [unchecked]" : "   [checked]"));
    }

    public static void main(String[] args) {
        chain(FileNotFoundException.class);
        chain(IOException.class);
        chain(Exception.class);
        chain(NullPointerException.class);
        chain(NumberFormatException.class);
        chain(ArrayIndexOutOfBoundsException.class);
        chain(StackOverflowError.class);
        chain(ExceptionInInitializerError.class);
    }
}

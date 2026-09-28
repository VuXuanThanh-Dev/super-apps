// objective: 2.1
// Kiểu được phép trong switch cổ điển và giá trị null với String/enum.
public class Ex11_SwitchTypes {
    enum Color { RED, GREEN }

    public static void main(String[] args) {
        Color c = Color.GREEN;
        switch (c) {
            case RED -> System.out.println("red");        // nhãn enum: không viết Color.RED cũng được
            case Color.GREEN -> System.out.println("green (Java 21 cho phép tên đầy đủ)");
        }

        Integer boxed = 2;                                // wrapper được unboxing
        switch (boxed) { case 1 -> System.out.println("1"); case 2 -> System.out.println("2"); default -> {} }

        String s = null;
        try {
            switch (s) { case "a" -> System.out.println("a"); default -> System.out.println("d"); }
        } catch (NullPointerException e) {
            System.out.println("NPE: switch cổ điển trên String null");
        }
        long big = 1L;
        // switch (big) { case 1L -> ... }   // lỗi: long/float/double/boolean không dùng trong switch cổ điển
        System.out.println("long không dùng làm selector (trừ khi là pattern trên Object) " + big);
    }
}

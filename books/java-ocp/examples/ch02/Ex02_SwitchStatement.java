// objective: 2.1
// switch statement kiểu cũ: rơi xuống (fall-through), default ở giữa, case phải là hằng số.
public class Ex02_SwitchStatement {
    static void test(int day) {
        final int WEEKEND = 6;
        System.out.print(day + ": ");
        switch (day) {
            case 1:
                System.out.print("Mon ");
            case 2:
                System.out.print("Tue ");
                break;
            default:
                System.out.print("Other ");
            case WEEKEND, 7:                // nhiều nhãn trên một case (Java 14+)
                System.out.print("Weekend ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        test(1);
        test(2);
        test(4);
        test(7);

        String cmd = "stop";
        switch (cmd) {                      // switch trên String dùng equals()
            case "start" -> System.out.println("starting");
            case "stop" -> System.out.println("stopping");
            default -> System.out.println("unknown");
        }
        char c = 'b';
        switch (c) { case 'a': case 'b': System.out.println("a or b"); }
    }
}

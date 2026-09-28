// objective: 2.1
// expect: compile-error
// switch expression trên int phải đầy đủ (exhaustive): thiếu default là lỗi.
public class Ex10_NotExhaustive {
    public static void main(String[] args) {
        int n = 2;
        String s = switch (n) {
            case 1 -> "one";
            case 2 -> "two";
        };
    }
}

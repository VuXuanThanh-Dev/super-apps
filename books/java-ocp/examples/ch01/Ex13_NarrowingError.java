// objective: 1.1, 1.2
// expect: compile-error
// Gán long cho int và dùng kết quả byte + byte mà không ép kiểu: javac báo lỗi.
public class Ex13_NarrowingError {
    public static void main(String[] args) {
        long big = 10L;
        int small = big;
        byte a = 1, b = 2;
        byte c = a + b;
        float f = 3.14;
    }
}

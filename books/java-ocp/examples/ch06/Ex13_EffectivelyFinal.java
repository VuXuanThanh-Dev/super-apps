// objective: 6.1, 3.6
// expect: compile-error
// Lambda chỉ dùng được biến cục bộ final hoặc effectively final (không bị gán lại ở bất kỳ đâu).
public class Ex13_EffectivelyFinal {
    public static void main(String[] args) {
        int count = 0;
        Runnable r = () -> System.out.println(count);
        count++;                       // gán lại SAU lambda vẫn làm count mất tính effectively final
        int[] box = {0};
        Runnable ok = () -> box[0]++;  // OK: tham chiếu box không đổi, chỉ nội dung mảng đổi
    }
}

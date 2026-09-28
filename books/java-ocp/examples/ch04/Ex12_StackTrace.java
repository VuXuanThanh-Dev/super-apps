// objective: 4.1
// expect: exception
// Exception không được bắt: JVM in stack trace ra System.err và kết thúc với exit code 1.
public class Ex12_StackTrace {
    static int depth(int n) {
        if (n == 0) throw new IllegalStateException("reached bottom");
        return depth(n - 1);
    }

    public static void main(String[] args) {
        System.out.println("before");
        depth(2);
        System.out.println("never printed");
    }
}

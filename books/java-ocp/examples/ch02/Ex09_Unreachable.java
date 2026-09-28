// objective: 2.1
// expect: compile-error
// Code không thể tới (unreachable) là lỗi biên dịch.
public class Ex09_Unreachable {
    public static void main(String[] args) {
        while (true) {
            break;
            System.out.println("sau break");
        }
        for (int i = 0; ; i++) { }
        System.out.println("sau vòng lặp vô hạn");
    }
}

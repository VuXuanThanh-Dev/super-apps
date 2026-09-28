// objective: 4.1
// expect: compile-error
// Lỗi biên dịch: catch lớp cha trước lớp con; catch checked exception không thể xảy ra; chưa xử lý checked.
import java.io.FileNotFoundException;
import java.io.IOException;

public class Ex08_CatchOrder {
    static void read() throws IOException { }

    public static void main(String[] args) {
        try {
            read();
        } catch (IOException e) {
        } catch (FileNotFoundException e) {        // đã bị catch IOException bắt trước
        }

        try {
            System.out.println("no IO here");
        } catch (IOException e) {                  // khối try không thể ném IOException
        }

        read();                                    // checked exception chưa được bắt hay khai báo
    }
}

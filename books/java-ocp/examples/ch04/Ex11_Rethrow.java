// objective: 4.1
// Ném lại (rethrow) chính xác: catch (Exception e) rồi throw e — compiler biết kiểu thật là IOException.
import java.io.IOException;

public class Ex11_Rethrow {
    static void io(boolean fail) throws IOException {
        if (fail) throw new IOException("io");
    }

    static void precise(boolean fail) throws IOException {   // KHÔNG cần "throws Exception"
        try {
            io(fail);
        } catch (Exception e) {
            System.out.println("log: " + e.getMessage());
            throw e;                                          // e effectively final → rethrow chính xác
        }
    }

    static void wrap() {
        try {
            io(true);
        } catch (IOException e) {
            throw new RuntimeException("wrapped", e);        // đổi checked thành unchecked
        }
    }

    public static void main(String[] args) {
        try {
            precise(true);
        } catch (IOException e) {
            System.out.println("main caught " + e.getMessage());
        }
        try {
            wrap();
        } catch (RuntimeException e) {
            System.out.println(e.getMessage() + " <- " + e.getCause().getMessage());
        }
    }
}

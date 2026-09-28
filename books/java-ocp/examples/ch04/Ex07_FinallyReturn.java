// objective: 4.1
// return trong try và finally: giá trị trả về được "chốt" trước khi finally chạy; return trong finally thắng.
public class Ex07_FinallyReturn {
    static int a() {
        int x = 1;
        try {
            return x;          // giá trị 1 được chốt
        } finally {
            x = 99;            // không ảnh hưởng giá trị đã chốt
        }
    }

    static StringBuilder b() {
        StringBuilder sb = new StringBuilder("v1");
        try {
            return sb;         // chốt THAM CHIẾU
        } finally {
            sb.append("+finally");   // object vẫn bị sửa
        }
    }

    @SuppressWarnings("finally")
    static int c() {
        try {
            throw new RuntimeException("lost");
        } finally {
            return 3;          // nuốt luôn exception
        }
    }

    public static void main(String[] args) {
        System.out.println(a() + " " + b() + " " + c());
    }
}

// objective: 3.1
// Vòng đời object: tạo bằng new, gán lại tham chiếu, và khi nào object "đủ điều kiện" bị GC.
public class Ex01_Lifecycle {
    static int created = 0;
    final String name;

    Ex01_Lifecycle(String name) {
        this.name = name;
        created++;
    }

    public static void main(String[] args) {
        Ex01_Lifecycle a = new Ex01_Lifecycle("A");   // object A
        Ex01_Lifecycle b = new Ex01_Lifecycle("B");   // object B
        Ex01_Lifecycle c = a;                          // c và a cùng trỏ A (không tạo object mới)
        System.out.println("created=" + created + " a==c? " + (a == c));

        a = b;          // A vẫn còn tham chiếu c
        c = null;       // bây giờ không còn tham chiếu nào tới A → A đủ điều kiện GC (eligible)
        System.out.println("a=" + a.name + " b=" + b.name + " c=" + c);

        new Ex01_Lifecycle("C");                       // tạo ra rồi bỏ ngay → đủ điều kiện GC
        System.out.println("created=" + created);
        System.gc();    // chỉ là "gợi ý"; JVM không bảo đảm sẽ chạy GC
        // Không có cách chắc chắn để biết lúc nào object bị thu hồi; finalize() đã deprecated.
    }
}

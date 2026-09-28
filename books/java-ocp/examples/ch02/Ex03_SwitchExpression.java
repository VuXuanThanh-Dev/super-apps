// objective: 2.1
// switch expression: trả về giá trị, dùng -> hoặc yield, phải đầy đủ (exhaustive).
public class Ex03_SwitchExpression {
    enum Size { S, M, L, XL }

    static int price(Size s) {
        return switch (s) {            // enum: liệt kê đủ hằng số thì không cần default
            case S, M -> 10;
            case L -> 12;
            case XL -> {
                int base = 12;
                yield base + 3;       // khối { } phải dùng yield
            }
        };
    }

    public static void main(String[] args) {
        for (Size s : Size.values()) System.out.print(s + "=" + price(s) + " ");
        System.out.println();

        int n = 3;
        String word = switch (n) {
            case 1: yield "one";          // dạng ':' cũng dùng được trong switch expression
            case 2: yield "two";
            default: yield "many";
        };
        System.out.println(word);

        var kind = switch ("b") {
            case "a" -> 1;
            case "b" -> 2.5;           // kiểu chung của các nhánh: double
            default -> 0;
        };
        System.out.println(kind);
    }
}

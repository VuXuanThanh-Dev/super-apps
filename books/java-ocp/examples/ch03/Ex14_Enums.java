// objective: 3.7
// Enum có field, constructor (luôn private), method, và method riêng cho từng hằng số.
public class Ex14_Enums {
    enum Planet {
        MERCURY(3.7), EARTH(9.8) {
            @Override String note() { return "home"; }       // thân riêng của hằng số
        }, MARS(3.7);

        private final double gravity;
        Planet(double gravity) {                             // constructor enum ngầm private
            this.gravity = gravity;
            System.out.println("init " + name());            // chạy khi enum được nạp lần đầu
        }
        double weight(double mass) { return mass * gravity; }
        String note() { return "-"; }
    }

    enum Op {
        ADD { int apply(int a, int b) { return a + b; } },
        SUB { int apply(int a, int b) { return a - b; } };
        abstract int apply(int a, int b);                    // mỗi hằng số phải cài đặt
    }

    public static void main(String[] args) {
        System.out.println("start");
        Planet p = Planet.valueOf("EARTH");
        System.out.println(p + " " + p.ordinal() + " " + p.weight(10) + " " + p.note() + " " + Planet.MARS.note());
        System.out.println(Planet.values().length + " " + (Planet.MARS.compareTo(Planet.EARTH) > 0));
        for (Op op : Op.values()) System.out.print(op + "=" + op.apply(7, 2) + " ");
        System.out.println();
        System.out.println(Planet.EARTH.getClass() == Planet.class);   // hằng số có thân là lớp con ẩn danh
        try {
            Planet.valueOf("earth");
        } catch (IllegalArgumentException e) {
            System.out.println("IllegalArgumentException: valueOf phân biệt hoa thường");
        }
    }
}

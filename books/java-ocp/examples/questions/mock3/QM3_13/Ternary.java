public class Ternary {
    public static void main(String[] args) {
        int a = 5;
        Object o1 = true ? a : "x";
        Object o2 = true ? 1 : 2.0;
        Object o3 = false ? 'A' : 66;
        System.out.println(o1.getClass().getSimpleName() + " " + o2 + " " + o3);
    }
}

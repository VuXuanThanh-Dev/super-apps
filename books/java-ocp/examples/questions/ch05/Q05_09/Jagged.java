public class Jagged {
    public static void main(String[] args) {
        int[][] a = new int[3][];
        a[0] = new int[2];
        System.out.println(a.length + " " + a[0].length + " " + a[0][1] + " " + a[1]);
    }
}

public class Shadow {
    static int x = 1;
    int y = 2;

    void run(int x) {
        int y = x + this.y;
        x = 10;
        System.out.println(x + " " + y + " " + Shadow.x + " " + this.y);
    }

    public static void main(String[] args) {
        new Shadow().run(5);
    }
}

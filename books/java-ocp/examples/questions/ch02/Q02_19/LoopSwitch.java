public class LoopSwitch {
    public static void main(String[] args) {
        int total = 0;
        for (int i = 0; i < 5; i++) {
            switch (i) {
                case 1: continue;
                case 3: break;
                default: total += i;
            }
            total += 10;
        }
        System.out.println(total);
    }
}

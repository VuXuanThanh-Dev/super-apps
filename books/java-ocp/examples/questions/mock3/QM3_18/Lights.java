public class Lights {
    enum Light { RED, YELLOW, GREEN }

    static int wait(Light l) {
        int w = 0;
        switch (l) {
            case RED: w += 30;
            case YELLOW: w += 5; break;
            case GREEN: w += 0;
            default: w -= 1;
        }
        return w;
    }

    public static void main(String[] args) {
        System.out.println(wait(Light.RED) + " " + wait(Light.YELLOW) + " " + wait(Light.GREEN));
    }
}

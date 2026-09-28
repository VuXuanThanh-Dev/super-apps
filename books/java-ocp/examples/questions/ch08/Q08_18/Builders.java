public class Builders {
    public static void main(String[] args) {
        Thread v = Thread.ofVirtual().name("v-", 1).unstarted(() -> { });
        Thread p = Thread.ofPlatform().name("p").unstarted(() -> { });
        System.out.println(v.getName() + " " + v.isVirtual() + " " + p.isVirtual() + " " + v.getState());
    }
}

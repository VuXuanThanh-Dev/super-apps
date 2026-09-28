public class Leak {
    static final class Schedule {
        private final int[] days;
        Schedule(int[] days) { this.days = days; }
        int[] days() { return days.clone(); }
        int first() { return days[0]; }
    }

    public static void main(String[] args) {
        int[] input = {1, 2, 3};
        Schedule s = new Schedule(input);
        s.days()[0] = 99;
        input[1] = 42;
        System.out.println(s.first() + " " + s.days()[1]);
    }
}

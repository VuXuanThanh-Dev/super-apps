public class Days {
    enum Day {
        MON, TUE, WED, THU, FRI, SAT, SUN;
        boolean weekend() { return switch (this) { case SAT, SUN -> true; default -> false; }; }
    }

    public static void main(String[] args) {
        Day d = Day.valueOf("FRI");
        System.out.println(d.weekend() + " " + Day.values()[d.ordinal() + 2] + " " + d.compareTo(Day.MON) + " "
                + Day.SUN.weekend());
    }
}

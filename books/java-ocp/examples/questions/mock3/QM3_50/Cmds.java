public class Cmds {
    sealed interface Cmd permits Move, Stop { }
    enum Move implements Cmd { LEFT, RIGHT }
    record Stop() implements Cmd { }

    static String run(Cmd c) {
        return switch (c) {
            case Move.LEFT -> "L";
            case Move.RIGHT -> "R";
            case Stop s -> "S";
        };
    }

    public static void main(String[] args) {
        System.out.println(run(Move.RIGHT) + run(new Stop()) + run(Move.LEFT));
    }
}

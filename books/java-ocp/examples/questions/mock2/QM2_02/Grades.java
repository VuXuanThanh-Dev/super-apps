public class Grades {
    static int score(char g) {
        return switch (g) {
            case 'A': case 'B':
                yield 3;
            case 'C':
                System.out.print("C! ");
            case 'D':
                yield 1;
            default:
                yield 0;
        };
    }

    public static void main(String[] args) {
        System.out.println(score('B') + score('C') + score('X'));
    }
}

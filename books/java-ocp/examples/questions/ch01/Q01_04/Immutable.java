public class Immutable {
    public static void main(String[] args) {
        String s = "java";
        s.concat(" rocks");
        s.toUpperCase();
        StringBuilder sb = new StringBuilder("java");
        sb.append(" rocks");
        System.out.println(s + " | " + sb);
    }
}

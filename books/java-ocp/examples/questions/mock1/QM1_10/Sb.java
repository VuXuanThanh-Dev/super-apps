public class Sb {
    public static void main(String[] args) {
        String s = "Java";
        StringBuilder sb = new StringBuilder(s);
        s.concat("21");
        sb.append(21).insert(0, s.toLowerCase()).reverse();
        System.out.println(s + " " + sb + " " + sb.length());
    }
}

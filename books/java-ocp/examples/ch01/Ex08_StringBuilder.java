// objective: 1.3
// StringBuilder có thể thay đổi (mutable); các method trả về chính nó (method chaining).
public class Ex08_StringBuilder {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abc");
        sb.append(1).append('x').append(true);
        System.out.println(sb + " len=" + sb.length());
        sb.insert(0, "->").delete(2, 4).deleteCharAt(sb.length() - 1);
        System.out.println(sb);
        sb.reverse();
        System.out.println(sb);
        sb.setLength(3);
        System.out.println(sb + " " + sb.indexOf("u") + " " + sb.charAt(0));
        sb.replace(0, 1, "ZZZ").setCharAt(1, 'y');
        System.out.println(sb);

        StringBuilder a = new StringBuilder("hi");
        StringBuilder b = new StringBuilder("hi");
        System.out.println(a.equals(b) + " " + a.toString().equals(b.toString()) + " " + (a.compareTo(b) == 0));

        StringBuilder same = a.append("!");     // cùng một object
        System.out.println((same == a) + " " + a);

        String sub = a.substring(1);            // substring trả về String, không đổi a
        System.out.println(sub + " " + a);
    }
}

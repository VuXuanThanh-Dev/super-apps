// objective: 1.3
// String bất biến (immutable), string pool, các method hay gặp.
public class Ex07_Strings {
    public static void main(String[] args) {
        String s1 = "java";
        String s2 = "ja" + "va";          // hằng số compile-time → cùng object trong pool
        String part = "ja";
        String s3 = part + "va";          // tạo lúc chạy → object mới
        System.out.println((s1 == s2) + " " + (s1 == s3) + " " + s1.equals(s3) + " " + (s1 == s3.intern()));

        String s = "  Hello World  ";
        s.toUpperCase();                  // kết quả bị bỏ đi: String không đổi
        System.out.println("[" + s + "]");
        System.out.println("[" + s.strip() + "] [" + s.stripLeading() + "] [" + s.trim().toLowerCase() + "]");

        String t = "banana";
        System.out.println(t.indexOf('a') + " " + t.indexOf("an", 2) + " " + t.lastIndexOf('a')
                + " " + t.charAt(2) + " " + t.substring(1, 3) + " " + t.substring(3));
        System.out.println(t.replace('a', 'o') + " " + t.replace("an", "") + " " + t.contains("nan")
                + " " + t.startsWith("ban") + " " + t.startsWith("na", 2));
        System.out.println("ab".repeat(3) + " " + " ".isBlank() + " " + "".isEmpty() + " " + "A".compareTo("C")
                + " " + "abc".equalsIgnoreCase("ABC"));
        System.out.println(String.join("-", "a", "b", "c") + " " + "a,b,,c".split(",").length
                + " " + "x".concat("y") + " " + String.valueOf(3.0));
        System.out.println("%s has %d chars".formatted(t, t.length()));
        try {
            System.out.println(t.substring(4, 2));
        } catch (StringIndexOutOfBoundsException e) {
            System.out.println("StringIndexOutOfBoundsException");
        }
    }
}

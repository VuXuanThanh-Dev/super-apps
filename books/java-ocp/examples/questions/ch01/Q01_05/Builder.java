public class Builder {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("0123456789");
        sb.delete(2, 5).insert(3, "-").reverse();
        System.out.println(sb);
    }
}

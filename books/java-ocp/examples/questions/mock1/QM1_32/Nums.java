public class Nums {
    public static void main(String[] args) {
        Object[] items = {1, "two", 3.0, 'c', 4L};
        int n = 0;
        for (Object o : items)
            if (o instanceof Number num && num.intValue() > 1) n += num.intValue();
        System.out.println(n);
    }
}

public class Transform {
    interface Transformer<T, R> {
        R apply(T t);
        default <V> Transformer<T, V> andThen(Transformer<R, V> next) { return t -> next.apply(apply(t)); }
    }

    public static void main(String[] args) {
        Transformer<String, Integer> len = String::length;
        Transformer<String, String> desc = len.andThen(n -> n > 3 ? "long" : "short");
        System.out.println(desc.apply("java") + " " + desc.apply("go") + " "
                + len.andThen(Integer::toBinaryString).apply("abcde"));
    }
}

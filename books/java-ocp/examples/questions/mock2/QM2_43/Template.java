public class Template {
    abstract static class Report {
        final String title;
        Report(String t) {
            title = t;
            System.out.print(header() + " ");
        }
        abstract String body();
        String header() { return "[" + title + "]"; }
        final String render() { return header() + body(); }
    }

    static class Sales extends Report {
        int total = 5;
        Sales() { super("sales"); }
        String body() { return ":" + total; }
        @Override String header() { return "<" + title + ">"; }
    }

    public static void main(String[] args) {
        System.out.println(new Sales().render());
    }
}

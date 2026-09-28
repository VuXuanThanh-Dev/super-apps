public class Probe {
    public static void main(String[] args) {
        Module m = Probe.class.getModule();
        System.out.println(m.isNamed() + " " + m.getName() + " "
                + m.canRead(java.sql.Connection.class.getModule()));
    }
}

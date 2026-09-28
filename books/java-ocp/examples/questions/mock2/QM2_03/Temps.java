public class Temps {
    record Temp(double celsius) {
        Temp {
            if (celsius < -273.15) celsius = -273.15;
        }
        public double celsius() { return Math.round(celsius * 10) / 10.0; }
    }

    public static void main(String[] args) {
        Temp a = new Temp(21.456), b = new Temp(21.4), c = new Temp(-300);
        System.out.println(a.celsius() + " " + a.equals(b) + " " + c + " "
                + (a.hashCode() == new Temp(21.456).hashCode()));
    }
}

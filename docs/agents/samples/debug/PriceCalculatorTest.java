public class PriceCalculatorTest {
    public static void main(String[] args) {
        double actual = PriceCalculator.discounted(200, 15);
        if (actual != 170.0) {
            throw new AssertionError("expected 170.0 but was " + actual);
        }
        System.out.println("PASS");
    }
}

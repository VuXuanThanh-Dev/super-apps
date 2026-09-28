public class PriceCalculator {
    /** Returns the price after a percentage discount, e.g. (200, 15) -> 170.0 */
    public static double discounted(int price, int percent) {
        return price - price * (percent / 100);
    }
}

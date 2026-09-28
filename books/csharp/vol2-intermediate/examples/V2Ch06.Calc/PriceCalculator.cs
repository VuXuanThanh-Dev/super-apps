namespace V2Ch06.Calc;

public interface IDiscountPolicy
{
    decimal GetDiscountRate(string customerTier);
}

public sealed class DefaultDiscountPolicy : IDiscountPolicy
{
    public decimal GetDiscountRate(string customerTier) => customerTier switch
    {
        "gold" => 0.10m,
        "silver" => 0.05m,
        _ => 0m,
    };
}

public record CartItem(string Sku, decimal UnitPrice, int Quantity);

public class PriceCalculator(IDiscountPolicy discountPolicy)
{
    public const decimal VatRate = 0.08m;

    public decimal Subtotal(IEnumerable<CartItem> items)
    {
        ArgumentNullException.ThrowIfNull(items);
        decimal sum = 0;
        foreach (var item in items)
        {
            if (item.Quantity <= 0)
                throw new ArgumentOutOfRangeException(nameof(items), $"Số lượng của {item.Sku} phải > 0");
            sum += item.UnitPrice * item.Quantity;
        }
        return sum;
    }

    public decimal Total(IEnumerable<CartItem> items, string customerTier)
    {
        var subtotal = Subtotal(items);
        var discounted = subtotal * (1 - discountPolicy.GetDiscountRate(customerTier));
        return Math.Round(discounted * (1 + VatRate), 0, MidpointRounding.AwayFromZero);
    }
}

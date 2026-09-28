using V2Ch06.Calc;

namespace V2Ch06.Calc.Tests;

public class PriceCalculatorTests
{
    // Fake (test double): thay thế dependency thật để test độc lập
    private sealed class FixedDiscount(decimal rate) : IDiscountPolicy
    {
        public decimal GetDiscountRate(string customerTier) => rate;
    }

    private static readonly CartItem[] Cart =
    [
        new("KB", 500_000m, 1),
        new("MOUSE", 250_000m, 2),
    ];

    [Fact]
    public void Subtotal_SumsUnitPriceTimesQuantity()
    {
        // Arrange
        var calc = new PriceCalculator(new FixedDiscount(0));

        // Act
        var subtotal = calc.Subtotal(Cart);

        // Assert
        Assert.Equal(1_000_000m, subtotal);
    }

    [Fact]
    public void Subtotal_EmptyCart_IsZero()
    {
        var calc = new PriceCalculator(new FixedDiscount(0));
        Assert.Equal(0m, calc.Subtotal([]));
    }

    [Fact]
    public void Subtotal_ZeroQuantity_Throws()
    {
        var calc = new PriceCalculator(new FixedDiscount(0));
        var ex = Assert.Throws<ArgumentOutOfRangeException>(() => calc.Subtotal([new("X", 10m, 0)]));
        Assert.Contains("X", ex.Message);
    }

    [Theory]
    [InlineData("gold", 972_000)]     // 1,000,000 * 0.90 * 1.08
    [InlineData("silver", 1_026_000)] // 1,000,000 * 0.95 * 1.08
    [InlineData("basic", 1_080_000)]  // 1,000,000 * 1.08
    public void Total_AppliesTierDiscountAndVat(string tier, int expected)
    {
        var calc = new PriceCalculator(new DefaultDiscountPolicy());
        Assert.Equal(expected, calc.Total(Cart, tier));
    }

    [Fact]
    public void Total_UsesInjectedPolicy()
    {
        var calc = new PriceCalculator(new FixedDiscount(0.5m));
        Assert.Equal(540_000m, calc.Total(Cart, "anything"));
    }
}

// Fixture: dữ liệu dùng chung cho nhiều test (tạo 1 lần cho cả class)
public sealed class CatalogFixture
{
    public Dictionary<string, decimal> Prices { get; } = new() { ["KB"] = 500_000m, ["MOUSE"] = 250_000m };
}

public class CatalogTests(CatalogFixture fixture) : IClassFixture<CatalogFixture>
{
    [Fact]
    public void Catalog_HasKeyboard() => Assert.True(fixture.Prices.ContainsKey("KB"));

    [Fact]
    public void Catalog_PricesArePositive() => Assert.All(fixture.Prices.Values, p => Assert.True(p > 0));
}

// Bài 1: Retry<T>(Func<T>, maxAttempts)
int attempts = 0;
int result = Retry(() =>
{
    attempts++;
    if (attempts < 3) throw new TimeoutException($"lần {attempts} lỗi");
    return 42;
}, maxAttempts: 5, onError: ex => Console.WriteLine($"Bài 1: thử lại vì: {ex.Message}"));
Console.WriteLine($"Bài 1: kết quả {result} sau {attempts} lần");

// Bài 2: Compose hai hàm
Func<int, int> addOne = x => x + 1;
Func<int, int> twice = x => x * 2;
var addThenTwice = Compose(addOne, twice);
Console.WriteLine($"Bài 2: Compose(addOne, twice)(5) = {addThenTwice(5)}");

// Bài 3: event PriceChanged trên Stock, chỉ báo khi thay đổi > 5%
var stock = new Stock("VNM", 100m);
stock.PriceChanged += (_, e) => Console.WriteLine($"Bài 3: {e.Symbol} {e.Old} -> {e.New} ({e.PercentChange:+0.0;-0.0}%)");
foreach (var p in new[] { 103m, 110m, 109m, 95m }) stock.Price = p;

static T Retry<T>(Func<T> action, int maxAttempts, Action<Exception>? onError = null)
{
    for (int i = 1; ; i++)
    {
        try { return action(); }
        catch (Exception ex) when (i < maxAttempts)
        {
            onError?.Invoke(ex);
        }
    }
}

static Func<T, TResult> Compose<T, TMid, TResult>(Func<T, TMid> first, Func<TMid, TResult> second)
    => x => second(first(x));

public record PriceChangedEventArgs(string Symbol, decimal Old, decimal New)
{
    public decimal PercentChange => (New - Old) / Old * 100;
}

public class Stock(string symbol, decimal price)
{
    private decimal _lastNotified = price;
    public event EventHandler<PriceChangedEventArgs>? PriceChanged;

    public decimal Price
    {
        get;
        set
        {
            field = value;
            var args = new PriceChangedEventArgs(symbol, _lastNotified, value);
            if (Math.Abs(args.PercentChange) > 5)
            {
                _lastNotified = value;
                PriceChanged?.Invoke(this, args);
            }
        }
    } = price;
}

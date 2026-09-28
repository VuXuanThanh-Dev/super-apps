// 1. Delegate tự khai báo
Calculate add = (a, b) => a + b;
Calculate mul = Multiply;               // method group
Console.WriteLine($"add(2,3)={add(2, 3)}, mul(2,3)={mul(2, 3)}");

// 2. Func và Action có sẵn
Func<int, int> square = x => x * x;
Func<string, int, string> repeat = (s, n) => string.Concat(Enumerable.Repeat(s, n));
Action<string> log = msg => Console.WriteLine($"[log] {msg}");
Predicate<int> isEven = n => n % 2 == 0;
log($"square(5)={square(5)}, repeat(\"ab\",3)={repeat("ab", 3)}, isEven(4)={isEven(4)}");

// 3. Hàm nhận hàm (higher-order function)
static List<TOut> Map<TIn, TOut>(IEnumerable<TIn> source, Func<TIn, TOut> f)
{
    var result = new List<TOut>();
    foreach (var item in source) result.Add(f(item));
    return result;
}
Console.WriteLine($"Map: {string.Join(", ", Map([1, 2, 3], x => $"#{x}"))}");

// 4. Closure: lambda "nhớ" biến bên ngoài
Func<int> MakeCounter()
{
    int count = 0;
    return () => ++count;
}
var next = MakeCounter();
Console.WriteLine($"Counter: {next()}, {next()}, {next()}");

// 5. Multicast delegate: một delegate gọi nhiều hàm
Action<string> pipeline = s => Console.WriteLine($"  bước 1: {s}");
pipeline += s => Console.WriteLine($"  bước 2: {s.ToUpper()}");
pipeline("xin chào");

// 6. Event: publisher / subscriber
var thermostat = new Thermostat();
thermostat.TemperatureChanged += (sender, e) =>
    Console.WriteLine($"  Nhiệt độ: {e.OldValue} -> {e.NewValue}");
EventHandler<TemperatureChangedEventArgs> alarm = (_, e) =>
{
    if (e.NewValue > 30) Console.WriteLine("  CẢNH BÁO: quá nóng!");
};
thermostat.TemperatureChanged += alarm;
thermostat.Temperature = 25;
thermostat.Temperature = 32;
thermostat.TemperatureChanged -= alarm;    // hủy đăng ký
thermostat.Temperature = 35;
thermostat.Temperature = 35;               // không đổi -> không phát event

// 7. C# 14: modifier trên tham số lambda không cần ghi kiểu
TryParser<int> parse = (text, out result) => int.TryParse(text, out result);
Console.WriteLine($"parse(\"12\") -> {parse("12", out var n)} ({n})");

static int Multiply(int a, int b) => a * b;

delegate int Calculate(int a, int b);
delegate bool TryParser<T>(string text, out T result);

public class TemperatureChangedEventArgs(double oldValue, double newValue) : EventArgs
{
    public double OldValue { get; } = oldValue;
    public double NewValue { get; } = newValue;
}

public class Thermostat
{
    public event EventHandler<TemperatureChangedEventArgs>? TemperatureChanged;

    public double Temperature
    {
        get;
        set
        {
            if (field == value) return;
            var old = field;
            field = value;
            TemperatureChanged?.Invoke(this, new TemperatureChangedEventArgs(old, value));
        }
    }
}

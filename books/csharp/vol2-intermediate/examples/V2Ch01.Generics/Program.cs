// 1. Generic method: một hàm dùng cho nhiều kiểu
static T Max<T>(T a, T b) where T : IComparable<T> => a.CompareTo(b) >= 0 ? a : b;

Console.WriteLine($"Max(3, 7) = {Max(3, 7)}");
Console.WriteLine($"Max(\"an\", \"binh\") = {Max("an", "binh")}");

// 2. Generic class
var intStack = new SimpleStack<int>();
intStack.Push(1);
intStack.Push(2);
Console.WriteLine($"Pop = {intStack.Pop()}, Count = {intStack.Count}");

// 3. Generic giữ kiểu lúc chạy (reified), khác Java type erasure
Console.WriteLine($"typeof(List<int>) = {typeof(List<int>).Name}<{typeof(List<int>).GenericTypeArguments[0].Name}>");
Console.WriteLine($"List<int> == List<string>? {typeof(List<int>) == typeof(List<string>)}");
Console.WriteLine($"C# 14 nameof(List<>) = {nameof(List<>)}");

// 4. Constraint: where T : class, new(), interface
var repo = new InMemoryRepository<Customer>();
repo.Add(new Customer { Id = 1, Name = "An" });
repo.Add(new Customer { Id = 2, Name = "Bình" });
Console.WriteLine($"Find(2) = {repo.Find(2)?.Name}; Find(9) = {repo.Find(9)?.Name ?? "null"}");
Console.WriteLine($"CreateDefault: {InMemoryRepository<Customer>.CreateDefault().Name}");

// 5. Generic math (static abstract members trong interface, .NET 7+)
static T Sum<T>(IEnumerable<T> values) where T : System.Numerics.INumber<T>
{
    T total = T.Zero;
    foreach (var v in values) total += v;
    return total;
}
Console.WriteLine($"Sum<int> = {Sum([1, 2, 3])}, Sum<decimal> = {Sum([1.5m, 2.25m])}");

// 6. Variance: IEnumerable<out T> là covariant
IEnumerable<string> names = ["x", "y"];
IEnumerable<object> objects = names;   // OK vì string là object
Console.WriteLine($"Covariance: {string.Join(",", objects)}");

// 7. Result<T>: kiểu generic tự viết, hay dùng để trả lỗi không cần exception
Result<int> ok = Result<int>.Ok(42);
Result<int> fail = Result<int>.Fail("không tìm thấy");
Console.WriteLine($"{ok} | {fail}");

public class SimpleStack<T>
{
    private readonly List<T> _items = [];
    public int Count => _items.Count;
    public void Push(T item) => _items.Add(item);
    public T Pop()
    {
        if (_items.Count == 0) throw new InvalidOperationException("Stack rỗng");
        T last = _items[^1];
        _items.RemoveAt(_items.Count - 1);
        return last;
    }
}

public interface IEntity
{
    int Id { get; }
}

public class Customer : IEntity
{
    public int Id { get; init; }
    public string Name { get; init; } = "(mặc định)";
}

public class InMemoryRepository<T> where T : class, IEntity, new()
{
    private readonly Dictionary<int, T> _store = [];
    public void Add(T entity) => _store[entity.Id] = entity;
    public T? Find(int id) => _store.GetValueOrDefault(id);
    public static T CreateDefault() => new();
}

public readonly record struct Result<T>(bool IsSuccess, T? Value, string? Error)
{
    public static Result<T> Ok(T value) => new(true, value, null);
    public static Result<T> Fail(string error) => new(false, default, error);
    public override string ToString() => IsSuccess ? $"Ok({Value})" : $"Fail({Error})";
}

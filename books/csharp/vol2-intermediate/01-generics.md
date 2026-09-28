# Chương 1 — Generics

## Mục tiêu

- Viết generic method và generic class.
- Dùng *constraint* (ràng buộc) `where T : ...`.
- Hiểu vì sao generics của C# khác Java (reified vs type erasure) và TypeScript.
- Biết *generic math* (`INumber<T>`) và *variance* (`out T`, `in T`) ở mức cơ bản.

## Giải thích đơn giản

*Generics* = viết code một lần, dùng cho nhiều kiểu. Bạn đã dùng `List<T>` ở Tập 1:
`List<int>`, `List<string>` là cùng một code, chỉ khác "tham số kiểu" `T`.

TypeScript có generics giống vậy: `function max<T>(a: T, b: T): T`. Điểm khác:

- TypeScript: kiểu biến mất sau khi biên dịch.
- Java: *type erasure* — lúc chạy `List<String>` chỉ là `List`.
- C#: *reified generics* — lúc chạy vẫn biết `List<int>` là `List<int>`. Nhờ vậy
  `new T()`, `typeof(T)`, `default(T)` đều dùng được, và `List<int>` không phải boxing.

## Ví dụ

<!-- include: examples/V2Ch01.Generics/Program.cs -->
```csharp
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
```

Output thật:

<!-- output: examples/V2Ch01.Generics -->
```text
Max(3, 7) = 7
Max("an", "binh") = binh
Pop = 2, Count = 1
typeof(List<int>) = List`1<Int32>
List<int> == List<string>? False
C# 14 nameof(List<>) = List
Find(2) = Bình; Find(9) = null
CreateDefault: (mặc định)
Sum<int> = 6, Sum<decimal> = 3.75
Covariance: x,y
Ok(42) | Fail(không tìm thấy)
```

`List`1` là tên thật của kiểu `List<T>` trong runtime (số 1 = có 1 tham số kiểu).

## Đi sâu

### Các loại constraint

| Constraint | Ý nghĩa |
|---|---|
| `where T : class` | T là reference type |
| `where T : struct` | T là value type (không null) |
| `where T : notnull` | T không phải kiểu nullable |
| `where T : new()` | T có constructor không tham số |
| `where T : BaseClass` | T là BaseClass hoặc lớp con |
| `where T : IInterface` | T implement interface |
| `where T : unmanaged` | T là value type không chứa reference (dùng với `Span`, pointer) |
| `where T : allows ref struct` | T có thể là `ref struct` (C# 13) |

Không có constraint, bạn chỉ gọi được các method của `object` trên `T`.
Constraint `IComparable<T>` cho phép gọi `a.CompareTo(b)` trong `Max<T>`.

### Generic math

Từ .NET 7, interface có thể có *static abstract member*. `INumber<T>` khai báo
`T.Zero`, toán tử `+`... nên `Sum<T>` ở trên chạy cho `int`, `decimal`, `double` mà không
cần viết lại. Đây là tính năng Java và TypeScript chưa có.

### Variance: `out` và `in`

- `IEnumerable<out T>` là *covariant*: `IEnumerable<string>` dùng được ở chỗ cần
  `IEnumerable<object>` (vì chỉ **đọc** T ra).
- `Action<in T>` là *contravariant*: `Action<object>` dùng được ở chỗ cần `Action<string>`
  (vì chỉ **nhận** T vào).
- `List<T>` **không** variant: `List<string>` không gán được cho `List<object>`, vì nếu được
  thì bạn có thể `Add(123)` vào list chuỗi.

### Khi nào tự viết generic?

- Code giống hệt nhau, chỉ khác kiểu: repository, cache, `Result<T>`, `Pair<T1,T2>`.
- Đừng lạm dụng: nếu chỉ có một kiểu dùng, viết kiểu cụ thể dễ đọc hơn.

## Lỗi và bẫy thường gặp

- **Quên constraint** → lỗi "Operator '>' cannot be applied to operands of type 'T'".
  Thêm `IComparable<T>` hoặc `INumber<T>`.
- **`default(T)` với reference type là `null`**: kiểm tra null khi trả về `T?`.
- **Nghĩ `List<Derived>` là `List<Base>`**: không phải. Dùng `IEnumerable<Base>` nếu chỉ đọc.
- **Static field trong generic class**: mỗi `T` có một bản riêng (`Cache<int>` và
  `Cache<string>` không chung static field).

## Tóm tắt

- Generics giúp viết code tái sử dụng, an toàn kiểu, không boxing.
- Constraint mở khóa các thao tác trên `T`.
- C# generics là reified: kiểu tồn tại lúc chạy.
- Generic math và variance là công cụ nâng cao nhưng rất hữu ích cho thư viện.

## Bài tập (có lời giải)

1. Viết `record Pair<T1, T2>` có method `Swap()` trả về `Pair<T2, T1>`.
2. Viết `FindMax<T>(IReadOnlyList<T>)` với constraint phù hợp; ném exception nếu rỗng.
3. Viết `LruCache<TKey, TValue>` dung lượng cố định: khi đầy, loại phần tử lâu nhất chưa dùng.

<details>
<summary>Lời giải</summary>

<!-- include: examples/V2Ch01.Solutions/Program.cs -->
```csharp
// Bài 1: Pair<T1, T2> với Swap
var pair = new Pair<string, int>("tuổi", 30);
Console.WriteLine($"Bài 1: {pair} -> {pair.Swap()}");

// Bài 2: FindMax<T> trên danh sách, ném lỗi nếu rỗng
Console.WriteLine($"Bài 2: {FindMax([3, 9, 2])}, {FindMax(["kiwi", "apple", "mango"])}");
try { FindMax(Array.Empty<int>()); }
catch (InvalidOperationException ex) { Console.WriteLine($"Bài 2: {ex.Message}"); }

// Bài 3: LruCache<TKey, TValue> giới hạn dung lượng
var cache = new LruCache<string, int>(capacity: 2);
cache.Set("a", 1); cache.Set("b", 2);
_ = cache.TryGet("a", out _);   // "a" vừa được dùng
cache.Set("c", 3);             // loại "b" (lâu nhất chưa dùng)
Console.WriteLine($"Bài 3: có a? {cache.TryGet("a", out _)}, có b? {cache.TryGet("b", out _)}, có c? {cache.TryGet("c", out _)}");

static T FindMax<T>(IReadOnlyList<T> items) where T : IComparable<T>
{
    if (items.Count == 0) throw new InvalidOperationException("Danh sách rỗng");
    T max = items[0];
    foreach (var item in items)
        if (item.CompareTo(max) > 0) max = item;
    return max;
}

public record Pair<T1, T2>(T1 First, T2 Second)
{
    public Pair<T2, T1> Swap() => new(Second, First);
}

public class LruCache<TKey, TValue>(int capacity) where TKey : notnull
{
    private readonly Dictionary<TKey, LinkedListNode<(TKey Key, TValue Value)>> _map = [];
    private readonly LinkedList<(TKey Key, TValue Value)> _order = new();

    public void Set(TKey key, TValue value)
    {
        if (_map.Remove(key, out var old)) _order.Remove(old);
        else if (_map.Count == capacity)
        {
            var lru = _order.Last!;
            _order.RemoveLast();
            _map.Remove(lru.Value.Key);
        }
        _map[key] = _order.AddFirst((key, value));
    }

    public bool TryGet(TKey key, out TValue? value)
    {
        if (_map.TryGetValue(key, out var node))
        {
            _order.Remove(node);
            _order.AddFirst(node);
            value = node.Value.Value;
            return true;
        }
        value = default;
        return false;
    }
}
```

<!-- output: examples/V2Ch01.Solutions -->
```text
Bài 1: Pair { First = tuổi, Second = 30 } -> Pair { First = 30, Second = tuổi }
Bài 2: 9, mango
Bài 2: Danh sách rỗng
Bài 3: có a? True, có b? False, có c? True
```

Bài 3 kết hợp `Dictionary` (tra cứu O(1)) và `LinkedList` (đổi thứ tự O(1)).
</details>

## Nguồn tham khảo (Sources)

- Generic types (C# fundamentals): https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/types/generics.md
- Generics in .NET: https://github.com/dotnet/docs/blob/main/docs/standard/generics.md
- Constraints on type parameters: https://github.com/dotnet/docs/blob/main/docs/csharp/programming-guide/generics/constraints-on-type-parameters.md
- Covariance and contravariance: https://github.com/dotnet/docs/blob/main/docs/standard/generics/covariance-and-contravariance.md
- Generic math: https://github.com/dotnet/docs/blob/main/docs/standard/generics/math.md
- Unbound generic types in `nameof` (C# 14): https://github.com/dotnet/csharplang/blob/main/proposals/csharp-14.0/unbound-generic-types-in-nameof.md

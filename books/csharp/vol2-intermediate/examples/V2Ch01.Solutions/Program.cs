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

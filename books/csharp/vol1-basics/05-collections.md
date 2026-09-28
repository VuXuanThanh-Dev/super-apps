# Chương 5 — Collections

## Mục tiêu

- Dùng mảng (array) một chiều và nhiều chiều.
- Dùng `List<T>`, `Dictionary<TKey, TValue>`, `HashSet<T>`, `Queue<T>`, `Stack<T>`.
- Dùng *collection expressions* `[1, 2, 3]` và *spread* `..`.
- Biết chọn collection phù hợp và tránh lỗi sửa collection khi đang duyệt.

## Giải thích đơn giản

*Collection* (tập hợp) là đối tượng chứa nhiều phần tử. So sánh nhanh:

| Việc cần | TypeScript | Java | C# |
|---|---|---|---|
| Danh sách động | `Array` / `T[]` | `ArrayList<T>` | `List<T>` |
| Mảng cố định | — | `T[]` | `T[]` |
| Khóa → giá trị | `Map<K,V>` / object | `HashMap<K,V>` | `Dictionary<TKey,TValue>` |
| Không trùng | `Set<T>` | `HashSet<T>` | `HashSet<T>` |
| Hàng đợi / ngăn xếp | tự viết | `ArrayDeque` | `Queue<T>` / `Stack<T>` |

Chữ `<T>` là *generic* — "danh sách của kiểu T". Tập 2 học generics kỹ hơn.
Khác Java: C# generics giữ kiểu lúc chạy, và `List<int>` chứa `int` thật (không boxing thành `Integer`).

## Ví dụ

<!-- include: examples/Ch05.Collections/Program.cs -->
```csharp
// 1. Array: kích thước cố định
int[] scores = [90, 75, 60, 88];
Array.Sort(scores);
Console.WriteLine($"Array đã sắp xếp: {string.Join(", ", scores)}; Length={scores.Length}");

int[,] matrix = { { 1, 2 }, { 3, 4 } };
Console.WriteLine($"matrix[1,0]={matrix[1, 0]}");

// 2. List<T>: mảng động
List<string> names = ["An", "Bình"];
names.Add("Chi");
names.Insert(0, "Dũng");
names.Remove("Bình");
Console.WriteLine($"List: {string.Join(", ", names)} (Count={names.Count})");
Console.WriteLine($"Có 'Chi'? {names.Contains("Chi")}; vị trí của 'Chi' = {names.IndexOf("Chi")}");
names.Sort();
Console.WriteLine($"Sau Sort: {string.Join(", ", names)}");

// 3. Dictionary<TKey, TValue>: tra cứu theo khóa
var stock = new Dictionary<string, int>
{
    ["apple"] = 10,
    ["banana"] = 5,
};
stock["cherry"] = 7;          // thêm hoặc ghi đè
stock["apple"] += 3;
if (stock.TryGetValue("banana", out int bananas))
    Console.WriteLine($"banana: {bananas}");
Console.WriteLine($"Có 'durian'? {stock.ContainsKey("durian")}");
foreach (var (fruit, qty) in stock)
    Console.WriteLine($"  {fruit,-7} = {qty}");

// 4. HashSet<T>: không trùng lặp, phép toán tập hợp
var backend = new HashSet<string> { "C#", "Java", "Go" };
var frontend = new HashSet<string> { "TypeScript", "C#" };
Console.WriteLine($"Add 'Java' lần 2: {backend.Add("Java")}");
var both = new HashSet<string>(backend);
both.IntersectWith(frontend);
Console.WriteLine($"Giao: {string.Join(", ", both)}");

// 5. Queue và Stack
var queue = new Queue<string>(["job1", "job2"]);
queue.Enqueue("job3");
Console.WriteLine($"Queue.Dequeue() = {queue.Dequeue()} (FIFO)");
var stack = new Stack<int>([1, 2]);
stack.Push(3);
Console.WriteLine($"Stack.Pop() = {stack.Pop()} (LIFO)");

// 6. Collection expressions và spread (..)
int[] a = [1, 2];
int[] b = [3, 4];
List<int> all = [.. a, .. b, 5];
Console.WriteLine($"Spread: [{string.Join(", ", all)}]");

// 7. Read-only views
IReadOnlyList<int> view = all.AsReadOnly();
Console.WriteLine($"Read-only view Count={view.Count}, phần tử cuối={view[^1]}");

// 8. Sửa collection khi đang foreach -> lỗi
try
{
    foreach (var n in all)
        if (n == 2) all.Remove(n);
}
catch (InvalidOperationException ex)
{
    Console.WriteLine($"Lỗi khi sửa trong foreach: {ex.GetType().Name}");
}
all.RemoveAll(n => n % 2 == 0);   // cách đúng
Console.WriteLine($"Sau RemoveAll số chẵn: [{string.Join(", ", all)}]");
```

Output thật:

<!-- output: examples/Ch05.Collections -->
```text
Array đã sắp xếp: 60, 75, 88, 90; Length=4
matrix[1,0]=3
List: Dũng, An, Chi (Count=3)
Có 'Chi'? True; vị trí của 'Chi' = 2
Sau Sort: An, Chi, Dũng
banana: 5
Có 'durian'? False
  apple   = 13
  banana  = 5
  cherry  = 7
Add 'Java' lần 2: False
Giao: C#
Queue.Dequeue() = job1 (FIFO)
Stack.Pop() = 3 (LIFO)
Spread: [1, 2, 3, 4, 5]
Read-only view Count=5, phần tử cuối=5
Lỗi khi sửa trong foreach: InvalidOperationException
Sau RemoveAll số chẵn: [1, 3, 5]
```

## Đi sâu

### Chọn collection nào?

| Collection | Thêm | Tìm theo khóa/giá trị | Truy cập theo index | Thứ tự |
|---|---|---|---|---|
| `T[]` | không (cố định) | O(n) | O(1) | giữ |
| `List<T>` | O(1) trung bình ở cuối | O(n) (`Contains`) | O(1) | giữ |
| `Dictionary<K,V>` | O(1) trung bình | O(1) theo khóa | — | không đảm bảo |
| `HashSet<T>` | O(1) trung bình | O(1) | — | không đảm bảo |
| `SortedDictionary<K,V>` | O(log n) | O(log n) | — | sắp theo khóa |
| `Queue<T>` / `Stack<T>` | O(1) | O(n) | — | FIFO / LIFO |

Quy tắc nhanh: cần tra cứu theo khóa → `Dictionary`; cần "có hay không" → `HashSet`;
còn lại → `List<T>`.

### Collection expressions (C# 12)

```csharp
int[] a = [1, 2];
List<int> list = [.. a, 3];     // spread: giống [...a, 3] trong TS
Span<int> span = [1, 2, 3];     // cũng dùng được với Span (Tập 3)
```

Cùng cú pháp `[...]` tạo được array, `List<T>`, `HashSet<T>`, `Span<T>`... Kiểu đích quyết định
collection nào được tạo.

### Duyệt `Dictionary`

`foreach (var (fruit, qty) in stock)` dùng *deconstruction* (tách) `KeyValuePair` thành 2 biến.
Thứ tự duyệt của `Dictionary` **không được đảm bảo** — đừng viết code phụ thuộc vào thứ tự.

### Interface của collection

Khi viết method, nhận tham số bằng interface nhỏ nhất bạn cần:

- `IEnumerable<T>`: chỉ cần duyệt (`foreach`, LINQ).
- `IReadOnlyList<T>` / `IReadOnlyCollection<T>`: cần `Count`, index, nhưng không sửa.
- `IList<T>`, `ICollection<T>`: cần sửa.

Trả về `IReadOnlyList<T>` để người gọi không sửa dữ liệu nội bộ của bạn
(như `BankAccount.History` ở Chương 4).

## Lỗi và bẫy thường gặp

- **Sửa collection khi đang `foreach`** → `InvalidOperationException`. Dùng `RemoveAll`,
  duyệt ngược bằng `for`, hoặc tạo list mới.
- **`dict[key]` khi key không tồn tại** → `KeyNotFoundException`. Dùng `TryGetValue`
  hoặc `GetValueOrDefault`.
- **Tưởng `Dictionary` giữ thứ tự thêm vào**: không đảm bảo.
- **Mảng có kích thước cố định**: không có `Add`. Cần thêm/xóa → dùng `List<T>`.
- **`List.Contains` trong vòng lặp lớn** → O(n²). Dùng `HashSet<T>`.

## Tóm tắt

- `List<T>` là collection dùng nhiều nhất; `Dictionary` để tra cứu; `HashSet` để loại trùng.
- `[ ... ]` và `..` tạo collection ngắn gọn như TypeScript.
- Trả về `IReadOnlyList<T>`/`IEnumerable<T>` để bảo vệ dữ liệu.
- Không sửa collection khi đang duyệt.

## Bài tập (có lời giải)

1. Đếm tần suất mỗi từ trong câu `"một hai ba hai ba ba"` bằng `Dictionary`.
2. Loại phần tử trùng trong `[3, 1, 3, 2, 1, 5]`, giữ thứ tự xuất hiện đầu tiên.
3. Kiểm tra chuỗi ngoặc `"(a[b]{c})"`, `"(]"`, `"(("` có cân bằng không, dùng `Stack<char>`.
4. Gộp `[5, 1]` và `[4, 9]` bằng spread, rồi sắp xếp giảm dần.

<details>
<summary>Lời giải</summary>

<!-- include: examples/Ch05.Solutions/Program.cs -->
```csharp
// Bài 1: đếm tần suất từ bằng Dictionary
string text = "một hai ba hai ba ba";
var freq = new Dictionary<string, int>();
foreach (var w in text.Split(' '))
{
    freq[w] = freq.GetValueOrDefault(w) + 1;
}
foreach (var (word, count) in freq) Console.WriteLine($"Bài 1: {word} = {count}");

// Bài 2: loại bỏ phần tử trùng, giữ thứ tự xuất hiện
int[] input = [3, 1, 3, 2, 1, 5];
var seen = new HashSet<int>();
var unique = new List<int>();
foreach (var n in input)
    if (seen.Add(n)) unique.Add(n);   // Add trả về false nếu đã có
Console.WriteLine($"Bài 2: [{string.Join(", ", unique)}]");

// Bài 3: kiểm tra dấu ngoặc cân bằng bằng Stack
foreach (var expr in new[] { "(a[b]{c})", "(]", "((" })
    Console.WriteLine($"Bài 3: {expr,-10} cân bằng? {IsBalanced(expr)}");

// Bài 4: gộp hai mảng bằng spread và sắp xếp giảm dần
int[] a = [5, 1], b = [4, 9];
List<int> merged = [.. a, .. b];
merged.Sort((x, y) => y.CompareTo(x));
Console.WriteLine($"Bài 4: [{string.Join(", ", merged)}]");

static bool IsBalanced(string s)
{
    var pairs = new Dictionary<char, char> { [')'] = '(', [']'] = '[', ['}'] = '{' };
    var stack = new Stack<char>();
    foreach (var c in s)
    {
        if (c is '(' or '[' or '{') stack.Push(c);
        else if (pairs.TryGetValue(c, out var open))
        {
            if (stack.Count == 0 || stack.Pop() != open) return false;
        }
    }
    return stack.Count == 0;
}
```

<!-- output: examples/Ch05.Solutions -->
```text
Bài 1: một = 1
Bài 1: hai = 2
Bài 1: ba = 3
Bài 2: [3, 1, 2, 5]
Bài 3: (a[b]{c})  cân bằng? True
Bài 3: (]         cân bằng? False
Bài 3: ((         cân bằng? False
Bài 4: [9, 5, 4, 1]
```

Bài 2 dùng mẹo: `HashSet.Add` trả về `false` nếu phần tử đã có.
</details>

## Nguồn tham khảo (Sources)

- Collections (C# fundamentals): https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/statements/collections.md
- Collections (language reference): https://github.com/dotnet/docs/blob/main/docs/csharp/language-reference/builtin-types/collections.md
- Collection expressions: https://github.com/dotnet/docs/blob/main/docs/csharp/language-reference/operators/collection-expressions.md
- Arrays: https://github.com/dotnet/docs/blob/main/docs/csharp/language-reference/builtin-types/arrays.md
- Collection expressions proposal (C# 12): https://github.com/dotnet/csharplang/blob/main/proposals/csharp-12.0/collection-expressions.md

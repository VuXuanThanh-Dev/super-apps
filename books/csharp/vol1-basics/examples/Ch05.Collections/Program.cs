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

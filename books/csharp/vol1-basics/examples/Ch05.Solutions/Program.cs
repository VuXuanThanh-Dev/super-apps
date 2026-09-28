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

// Cùng một bài toán, viết bằng C#. So sánh với compare.ts và Compare.java.
List<User> users =
[
    new(1, "An", 28, "an@example.com"),
    new(2, "Bình", 17, null),
    new(3, "Chi", 35, "chi@example.com"),
];

// 1. Lọc + biến đổi (LINQ ~ filter/map trong TS, Stream trong Java)
var adults = users.Where(u => u.Age >= 18).Select(u => u.Name.ToUpper()).ToList();
Console.WriteLine($"Người lớn: {string.Join(", ", adults)}");

// 2. Null an toàn: ?. và ??
foreach (var u in users)
    Console.WriteLine($"{u.Name}: {u.Email?.Length.ToString() ?? "không có email"}");

// 3. Record: so sánh theo giá trị, copy bằng `with`
var older = users[0] with { Age = 29 };
var same = new User(1, "An", 28, "an@example.com");
Console.WriteLine(older);
Console.WriteLine($"users[0] == bản sao cùng dữ liệu? {users[0] == same}");

// 4. async/await
var name = await FindNameAsync(3);
Console.WriteLine($"Tìm thấy: {name}");

// 5. Exception
try
{
    await FindNameAsync(99);
}
catch (KeyNotFoundException ex)
{
    Console.WriteLine($"Lỗi: {ex.Message}");
}

async Task<string> FindNameAsync(int id)
{
    await Task.Delay(10);   // giả lập gọi DB/HTTP
    var user = users.FirstOrDefault(u => u.Id == id)
        ?? throw new KeyNotFoundException($"User {id} không tồn tại");
    return user.Name;
}

record User(int Id, string Name, int Age, string? Email);

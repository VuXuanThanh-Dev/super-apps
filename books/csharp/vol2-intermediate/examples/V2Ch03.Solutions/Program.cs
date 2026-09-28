Product[] products =
[
    new("Laptop", "Máy tính", 25_000_000m, 5),
    new("Chuột", "Phụ kiện", 300_000m, 50),
    new("Bàn phím", "Phụ kiện", 900_000m, 0),
    new("Màn hình", "Máy tính", 5_000_000m, 12),
    new("Tai nghe", "Phụ kiện", 1_200_000m, 8),
];

// Bài 1: 3 sản phẩm đắt nhất còn hàng
var top3 = products.Where(p => p.Stock > 0).OrderByDescending(p => p.Price).Take(3).Select(p => p.Name);
Console.WriteLine($"Bài 1: {string.Join(", ", top3)}");

// Bài 2: theo danh mục: số sản phẩm và tổng giá trị tồn kho
var byCategory = products
    .GroupBy(p => p.Category)
    .Select(g => new { Category = g.Key, Count = g.Count(), Value = g.Sum(p => p.Price * p.Stock) })
    .OrderByDescending(x => x.Value);
foreach (var c in byCategory) Console.WriteLine($"Bài 2: {c.Category,-9} {c.Count} sp, tồn kho {c.Value,15:N0}");

// Bài 3: 2 từ xuất hiện nhiều nhất (không phân biệt hoa thường)
string text = "C# và LINQ. LINQ rất mạnh; C# rất gọn. linq!";
var topWords = text
    .Split([' ', '.', ';', '!'], StringSplitOptions.RemoveEmptyEntries)
    .GroupBy(w => w.ToLowerInvariant())
    .OrderByDescending(g => g.Count()).ThenBy(g => g.Key)
    .Take(2)
    .Select(g => $"{g.Key}={g.Count()}");
Console.WriteLine($"Bài 3: {string.Join(", ", topWords)}");

// Bài 4: tên sản phẩm hết hàng (hoặc "không có")
var outOfStock = products.Where(p => p.Stock == 0).Select(p => p.Name).DefaultIfEmpty("không có");
Console.WriteLine($"Bài 4: hết hàng: {string.Join(", ", outOfStock)}");

record Product(string Name, string Category, decimal Price, int Stock);

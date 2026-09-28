// Bài 1: đổi nhiệt độ C -> F, làm tròn 1 chữ số
double celsius = 36.6;
double fahrenheit = celsius * 9 / 5 + 32;
Console.WriteLine($"Bài 1: {celsius}°C = {fahrenheit:F1}°F");

// Bài 2: tính tiền với decimal (không dùng double cho tiền)
decimal unitPrice = 19_990m;
int quantity = 3;
decimal vat = 0.08m;
decimal total = unitPrice * quantity * (1 + vat);
Console.WriteLine($"Bài 2: tổng tiền = {total:N0} VND");

// Bài 3: đọc số an toàn bằng TryParse
foreach (var input in new[] { "25", "hai mươi", "" })
{
    string result = int.TryParse(input, out int age) ? $"tuổi = {age}" : "không hợp lệ";
    Console.WriteLine($"Bài 3: '{input}' -> {result}");
}

// Bài 4: đảo ngược chuỗi và đếm nguyên âm
string text = "Lap trinh CSharp";
char[] chars = text.ToCharArray();
Array.Reverse(chars);
int vowels = text.ToLower().Count(c => "aeiou".Contains(c));
Console.WriteLine($"Bài 4: đảo ngược = '{new string(chars)}', số nguyên âm = {vowels}");

// 1. Khai báo biến: kiểu rõ ràng hoặc var (suy luận kiểu lúc biên dịch)
int age = 30;
var price = 19.99m;          // m = decimal (tiền tệ)
double ratio = 1.0 / 3;
bool isActive = true;
char grade = 'A';
Console.WriteLine($"age={age}, price={price}, ratio={ratio}, isActive={isActive}, grade={grade}");
Console.WriteLine($"Kiểu của price: {price.GetType().Name}");

// 2. Giới hạn và tràn số
Console.WriteLine($"int: {int.MinValue} .. {int.MaxValue}");
int big = int.MaxValue;
int overflow = unchecked(big + 1);
Console.WriteLine($"int.MaxValue + 1 (unchecked) = {overflow}");
try
{
    int boom = checked(big + 1);
    Console.WriteLine(boom);
}
catch (OverflowException ex)
{
    Console.WriteLine($"checked: {ex.GetType().Name}");
}

// 3. double và decimal
Console.WriteLine($"0.1 + 0.2 (double)  = {0.1 + 0.2}");
Console.WriteLine($"0.1 + 0.2 (decimal) = {0.1m + 0.2m}");

// 4. Chuyển kiểu
long l = age;                 // ngầm định (an toàn)
int back = (int)3.99;         // ép kiểu: cắt phần thập phân
int parsed = int.Parse("42");
bool ok = int.TryParse("abc", out int value);
Console.WriteLine($"l={l}, (int)3.99={back}, parsed={parsed}, TryParse(\"abc\")={ok}, value={value}");

// 5. Value type vs reference type
int a = 1;
int b = a;    // copy giá trị
b = 2;
int[] arr1 = [1, 2, 3];
int[] arr2 = arr1;  // copy tham chiếu: cùng một mảng
arr2[0] = 99;
Console.WriteLine($"a={a}, b={b}; arr1[0]={arr1[0]} (vì arr2 trỏ cùng mảng)");

// 6. Nullable
int? maybe = null;
Console.WriteLine($"maybe.HasValue={maybe.HasValue}, maybe ?? -1 = {maybe ?? -1}");
string? nickname = null;
Console.WriteLine($"Độ dài nickname: {nickname?.Length ?? 0}");

// 7. const và hằng số
const double Pi = 3.14159;
Console.WriteLine($"Diện tích hình tròn r=2: {Pi * 2 * 2:F2}");

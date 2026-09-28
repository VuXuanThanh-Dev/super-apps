# Chương 7 — C# cho Java và TypeScript developer

## Mục tiêu

- Chuyển nhanh kiến thức TypeScript và Java sang C# bằng bảng so sánh song song.
- Chạy **cùng một bài toán** bằng 3 ngôn ngữ và so sánh output.
- Biết những thói quen cần "quên đi" khi viết C#.

## Giải thích đơn giản

Nếu bạn biết TypeScript và đang học Java, bạn đã biết khoảng 70% C#:

- **Cú pháp và OOP** gần như Java (class, interface, `new`, kiểu tĩnh, một class cha).
- **Tính năng hiện đại** gần như TypeScript (lambda `=>`, `?.`, `??`, `async/await`,
  type inference với `var`, string interpolation).
- **Điểm riêng của C#**: property, LINQ, `struct`, `record`, generics giữ kiểu lúc chạy,
  pattern matching, `ref`/`out`.

## Ví dụ

Bài toán: danh sách user → lọc người lớn → in email nếu có → copy record → tìm user bất đồng bộ
→ xử lý lỗi.

### C#

<!-- include: examples/Ch07.Compare/Program.cs -->
```csharp
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
```

<!-- output: examples/Ch07.Compare -->
```text
Người lớn: AN, CHI
An: 14
Bình: không có email
Chi: 15
User { Id = 1, Name = An, Age = 29, Email = an@example.com }
users[0] == bản sao cùng dữ liệu? True
Tìm thấy: Chi
Lỗi: User 99 không tồn tại
```

### TypeScript

<!-- include: examples/Ch07.TypeScript/compare.ts -->
```typescript
// Same problem in TypeScript.
type User = { readonly id: number; readonly name: string; readonly age: number; readonly email: string | null };

const users: User[] = [
  { id: 1, name: "An", age: 28, email: "an@example.com" },
  { id: 2, name: "Bình", age: 17, email: null },
  { id: 3, name: "Chi", age: 35, email: "chi@example.com" },
];

// 1. filter + map
const adults = users.filter(u => u.age >= 18).map(u => u.name.toUpperCase());
console.log(`Người lớn: ${adults.join(", ")}`);

// 2. ?. and ??
for (const u of users) console.log(`${u.name}: ${u.email?.length.toString() ?? "không có email"}`);

// 3. spread copy (no built-in value equality)
const older = { ...users[0], age: 29 };
const same: User = { id: 1, name: "An", age: 28, email: "an@example.com" };
console.log(JSON.stringify(older));
console.log(`users[0] === bản sao cùng dữ liệu? ${users[0] === same}`);

async function findNameAsync(id: number): Promise<string> {
  await new Promise(r => setTimeout(r, 10));
  const user = users.find(u => u.id === id);
  if (!user) throw new Error(`User ${id} không tồn tại`);
  return user.name;
}

async function main() {
  // 4. async/await
  console.log(`Tìm thấy: ${await findNameAsync(3)}`);
  // 5. exceptions
  try {
    await findNameAsync(99);
  } catch (e) {
    console.log(`Lỗi: ${(e as Error).message}`);
  }
}
main();
```

<!-- output: examples/Ch07.TypeScript -->
```text
$ tsc --version
Version 6.0.2
$ tsc --strict --target es2022 --module nodenext --outDir out compare.ts && node out/compare.js
Người lớn: AN, CHI
An: 14
Bình: không có email
Chi: 15
{"id":1,"name":"An","age":29,"email":"an@example.com"}
users[0] === bản sao cùng dữ liệu? false
Tìm thấy: Chi
Lỗi: User 99 không tồn tại
```

### Java 21

<!-- include: examples/Ch07.Java/Compare.java -->
```java
// Same problem in Java 21.
import java.util.*;
import java.util.concurrent.*;

public class Compare {
    record User(int id, String name, int age, String email) {}

    static final List<User> users = List.of(
        new User(1, "An", 28, "an@example.com"),
        new User(2, "Bình", 17, null),
        new User(3, "Chi", 35, "chi@example.com"));

    static CompletableFuture<String> findNameAsync(int id) {
        return CompletableFuture.supplyAsync(() -> {
            try { Thread.sleep(10); } catch (InterruptedException e) { throw new RuntimeException(e); }
            return users.stream().filter(u -> u.id() == id).findFirst()
                .orElseThrow(() -> new NoSuchElementException("User " + id + " không tồn tại"))
                .name();
        });
    }

    public static void main(String[] args) {
        // 1. Stream filter + map
        var adults = users.stream().filter(u -> u.age() >= 18).map(u -> u.name().toUpperCase()).toList();
        System.out.println("Người lớn: " + String.join(", ", adults));

        // 2. Null: Optional (Java has no ?. operator)
        for (var u : users)
            System.out.println(u.name() + ": " + Optional.ofNullable(u.email()).map(e -> String.valueOf(e.length())).orElse("không có email"));

        // 3. Record: value equality, but no `with` (make a new one)
        var first = users.get(0);
        var older = new User(first.id(), first.name(), 29, first.email());
        var same = new User(1, "An", 28, "an@example.com");
        System.out.println(older);
        System.out.println("users[0].equals(bản sao cùng dữ liệu)? " + first.equals(same));

        // 4. async (CompletableFuture) - join() blocks here
        System.out.println("Tìm thấy: " + findNameAsync(3).join());

        // 5. Exception
        try {
            findNameAsync(99).join();
        } catch (CompletionException ex) {
            System.out.println("Lỗi: " + ex.getCause().getMessage());
        }
    }
}
```

<!-- output: examples/Ch07.Java -->
```text
$ java --version
openjdk 21.0.10 2026-01-20
$ java Compare.java
Người lớn: AN, CHI
An: 14
Bình: không có email
Chi: 15
User[id=1, name=An, age=29, email=an@example.com]
users[0].equals(bản sao cùng dữ liệu)? true
Tìm thấy: Chi
Lỗi: User 99 không tồn tại
```

Kết quả giống nhau, trừ dòng so sánh bằng nhau: C# `record` và Java `record` so sánh theo
**giá trị** (`True`/`true`), còn object TypeScript so sánh theo **tham chiếu** (`false`).

## Đi sâu — bảng so sánh song song

### 1. Công cụ và project

| Việc | TypeScript | Java | C# |
|---|---|---|---|
| Runtime | Node.js | JVM | .NET Runtime (CLR) |
| Biên dịch | `tsc` → JS | `javac` → bytecode | Roslyn → IL |
| File project | `package.json`, `tsconfig.json` | `pom.xml` / `build.gradle` | `*.csproj` (+ `Directory.Build.props`) |
| Kho gói | npm | Maven Central | NuGet |
| Thêm gói | `npm i zod` | sửa `pom.xml` | `dotnet add package X` |
| Chạy một file | `node a.js` | `java A.java` | `dotnet run a.cs` (.NET 10) |
| Test | Jest / Vitest | JUnit | xUnit / NUnit / MSTest |

### 2. Kiểu dữ liệu

| Khái niệm | TypeScript | Java | C# |
|---|---|---|---|
| Số nguyên | `number` | `int`, `long` | `int`, `long` |
| Số thực | `number` | `double` | `double`, `decimal` (tiền) |
| Chuỗi | `string` | `String` | `string` (= `System.String`) |
| Suy luận kiểu | `let x = 1` | `var x = 1;` | `var x = 1;` |
| Hằng | `const` | `final` | `const` (lúc biên dịch), `readonly` (field) |
| Any | `any` / `unknown` | `Object` | `object` (hoặc `dynamic`, hiếm dùng) |
| Union | `'a' \| 'b'` | sealed interface + record | `enum`, hoặc class hierarchy (union thật: C# 15, preview) |
| Tuple | `[number, string]` | không có sẵn | `(int, string)` |
| Kiểu tự định nghĩa value type | không | không (Java 21) | `struct` |

### 3. Null

| | TypeScript | Java | C# |
|---|---|---|---|
| Khai báo có thể null | `string \| null` | mọi object | `string?` |
| Truy cập an toàn | `a?.b` | `Optional.map` | `a?.b` |
| Giá trị mặc định | `a ?? b` | `Optional.orElse` | `a ?? b` |
| Gán nếu null | `a ??= b` | — | `a ??= b` |
| Gán có điều kiện | — | — | `a?.b = c` (C# 14) |
| "Tôi chắc không null" | `a!` | — | `a!` |

### 4. Class và property

| | TypeScript | Java | C# |
|---|---|---|---|
| Property | `get x()` / field public | getter/setter | `public int X { get; set; }` |
| Chỉ đọc | `readonly x` | `final` field + getter | `{ get; }` hoặc `{ get; init; }` |
| Constructor ngắn | `constructor(private x: number)` | record | primary constructor `class A(int x)` |
| Override | tự động | tự động (`@Override`) | phải `virtual` + `override` |
| Không cho kế thừa | — | `final class` | `sealed class` |
| Extension method | — | — | `static` method với `this` hoặc khối `extension` (C# 14) |

### 5. Collections và xử lý dữ liệu

| | TypeScript | Java | C# (LINQ) |
|---|---|---|---|
| Lọc | `arr.filter(f)` | `stream().filter(f)` | `list.Where(f)` |
| Biến đổi | `arr.map(f)` | `.map(f)` | `.Select(f)` |
| Gộp | `arr.reduce(f, 0)` | `.reduce(0, f)` | `.Aggregate(0, f)` / `.Sum()` |
| Tìm | `arr.find(f)` | `.filter(f).findFirst()` | `.FirstOrDefault(f)` |
| Có phần tử? | `arr.some(f)` | `.anyMatch(f)` | `.Any(f)` |
| Nhóm | `Object.groupBy` | `Collectors.groupingBy` | `.GroupBy(f)` |
| Kết quả | mảng (ngay) | stream (lười) | `IEnumerable` (lười) → `.ToList()` |

### 6. Bất đồng bộ

| | TypeScript | Java | C# |
|---|---|---|---|
| Kiểu | `Promise<T>` | `CompletableFuture<T>` | `Task<T>` |
| Hàm | `async function` | — | `async Task<T> M()` |
| Chờ | `await p` | `.join()` / `.get()` (block) | `await t` |
| Chờ nhiều | `Promise.all` | `CompletableFuture.allOf` | `Task.WhenAll` |
| Hủy | `AbortController` | `cancel()` | `CancellationToken` |
| Luồng | 1 luồng + event loop | nhiều thread / virtual threads | thread pool; `await` không chặn thread |

### 7. Generics

- TypeScript: chỉ tồn tại lúc biên dịch, **structural** (so theo hình dạng).
- Java: *type erasure* — lúc chạy `List<String>` và `List<Integer>` là cùng một kiểu;
  không dùng được `List<int>`.
- C#: *reified* — lúc chạy vẫn biết `List<int>` khác `List<string>`; `typeof(T)` dùng được;
  `List<int>` chứa `int` thật, không boxing.

### 8. Module và đặt tên

| | TypeScript | Java | C# |
|---|---|---|---|
| Nhóm code | module (`import`/`export`) | package | `namespace` |
| Import | `import { A } from './a'` | `import a.b.A;` | `using A.B;` |
| Phạm vi mặc định | file | package-private | `internal` (trong assembly) |
| Tên method | `camelCase` | `camelCase` | **`PascalCase`** |
| Tên property | `camelCase` | `getX()` | **`PascalCase`** |
| Field private | `#x` / `private x` | `x` | `_x` |
| Interface | `User` | `User` | **`IUser`** (tiền tố `I`) |

### 9. Lỗi

| | TypeScript | Java | C# |
|---|---|---|---|
| Checked exception | không | có (`throws`) | **không** |
| Bắt theo kiểu | không (`catch (e)`) | có | có, thêm `when (điều kiện)` |
| Giải phóng tài nguyên | `try/finally` | try-with-resources | `using` |

## Lỗi và bẫy thường gặp (thói quen cần quên)

- **Từ TypeScript**: `==` trong C# không ép kiểu như JS; không có `===`. Chia `int` cho `int`
  ra số nguyên. Object literal `{ a: 1 }` không có — dùng `new { A = 1 }` (anonymous type) hoặc record.
- **Từ TypeScript**: kiểu trong C# tồn tại lúc chạy; `obj is User u` kiểm tra kiểu thật.
- **Từ Java**: method không virtual mặc định; tên method viết hoa chữ đầu; `string` so sánh
  bằng `==` là **đúng** trong C# (khác `equals` của Java).
- **Từ Java**: không cần getter/setter thủ công — dùng property.
- **Cả hai**: không gọi `.Result` / `.Wait()` trên `Task` (dễ deadlock/chặn thread);
  dùng `await` từ đầu đến cuối ("async all the way").
- **Cả hai**: LINQ lười (lazy) giống Java stream: query chỉ chạy khi duyệt hoặc gọi `.ToList()`.

## Tóm tắt

- C# = cú pháp và OOP kiểu Java + tính năng hiện đại kiểu TypeScript.
- Cần học thêm: property, LINQ, `record`, `struct`, pattern matching, `Task`/`await`,
  quy tắc đặt tên PascalCase.
- Tập 2 đi sâu vào generics, LINQ, records, async — những thứ bảng trên chỉ giới thiệu.

## Bài tập (có lời giải)

1. Dịch đoạn TypeScript sau sang C#:
   `const total = orders.filter(o => o.paid).reduce((s, o) => s + o.amount, 0);`
2. Viết lại hàm Java trả về `Optional<String>` thành hàm C# trả về `string?`, và dùng `??` khi gọi.
3. TypeScript có `type Status = 'ok' | 'error'`. Viết tương đương trong C# bằng `enum` và
   switch expression.

<details>
<summary>Lời giải</summary>

<!-- include: examples/Ch07.Solutions/Program.cs -->
```csharp
// Bài 1: dịch đoạn TypeScript sau sang C#:
//   const total = orders.filter(o => o.paid).reduce((s, o) => s + o.amount, 0);
Order[] orders = [new(1, 100m, true), new(2, 50m, false), new(3, 70m, true)];
decimal total = orders.Where(o => o.Paid).Sum(o => o.Amount);
Console.WriteLine($"Bài 1: tổng đã thanh toán = {total}");

// Bài 2: Java Optional<String> -> C# nullable
string? FindEmail(int id) => id == 1 ? "an@example.com" : null;
Console.WriteLine($"Bài 2: {FindEmail(1) ?? "(none)"} | {FindEmail(2) ?? "(none)"}");

// Bài 3: TS union type 'ok' | 'error' -> C# enum + switch expression
foreach (var st in Enum.GetValues<Status>())
    Console.WriteLine($"Bài 3: {st} -> {Describe(st)}");

static string Describe(Status s) => s switch
{
    Status.Ok => "thành công",
    Status.Error => "thất bại",
    _ => throw new ArgumentOutOfRangeException(nameof(s)),
};

record Order(int Id, decimal Amount, bool Paid);
enum Status { Ok, Error }
```

<!-- output: examples/Ch07.Solutions -->
```text
Bài 1: tổng đã thanh toán = 170
Bài 2: an@example.com | (none)
Bài 3: Ok -> thành công
Bài 3: Error -> thất bại
```

Bài 1: `Where` = `filter`, `Sum(selector)` thay cho `reduce` khi chỉ cộng dồn.
Bài 3: nhánh `_ => throw ...` bảo vệ trường hợp giá trị enum không hợp lệ (enum trong C#
thực chất là số nguyên, có thể ép kiểu từ số bất kỳ).
</details>

## Nguồn tham khảo (Sources)

- Tour of C# (nguồn Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/csharp/tour-of-csharp/overview.md
- Tips for Java developers: https://github.com/dotnet/docs/blob/main/docs/csharp/tour-of-csharp/tips-for-java-developers.md
- Tips for JavaScript/TypeScript developers: https://github.com/dotnet/docs/blob/main/docs/csharp/tour-of-csharp/tips-for-javascript-developers.md
- C# identifier naming rules and conventions: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/coding-style/identifier-names.md
- Null-conditional assignment (C# 14 proposal): https://github.com/dotnet/csharplang/blob/main/proposals/csharp-14.0/null-conditional-assignment.md
- Unions (C# 15 proposal): https://github.com/dotnet/csharplang/blob/main/proposals/csharp-15.0/unions.md

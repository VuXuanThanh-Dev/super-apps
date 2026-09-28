# Chương 6 — Unit test với xUnit

## Mục tiêu

- Tạo project test xUnit v3 và chạy bằng `dotnet test` trên .NET 10.
- Viết test theo mẫu Arrange–Act–Assert với `[Fact]` và `[Theory]`.
- Test exception, dùng *test double* (fake) thay cho dependency thật.
- Dùng fixture (`IClassFixture<T>`) và `MemberData`.

## Giải thích đơn giản

*Unit test* là code kiểm tra một phần nhỏ (một class, một method) của chương trình.
So sánh với công cụ bạn biết:

| Jest / Vitest (TS) | JUnit 5 (Java) | xUnit (C#) |
|---|---|---|
| `test('...', () => {})` | `@Test` | `[Fact]` |
| `test.each([...])` | `@ParameterizedTest` | `[Theory]` + `[InlineData]` |
| `expect(x).toBe(y)` | `assertEquals(y, x)` | `Assert.Equal(y, x)` |
| `expect(fn).toThrow()` | `assertThrows` | `Assert.Throws<T>(...)` |
| `beforeAll` | `@BeforeAll` | `IClassFixture<T>` |
| `beforeEach` | `@BeforeEach` | constructor của class test |

Trong xUnit, **mỗi test chạy trên một object mới** của class test. Vì vậy constructor đóng vai
trò "setup" cho từng test.

## Ví dụ

### Code cần test (class library `V2Ch06.Calc`)

<!-- include: examples/V2Ch06.Calc/PriceCalculator.cs -->
```csharp
namespace V2Ch06.Calc;

public interface IDiscountPolicy
{
    decimal GetDiscountRate(string customerTier);
}

public sealed class DefaultDiscountPolicy : IDiscountPolicy
{
    public decimal GetDiscountRate(string customerTier) => customerTier switch
    {
        "gold" => 0.10m,
        "silver" => 0.05m,
        _ => 0m,
    };
}

public record CartItem(string Sku, decimal UnitPrice, int Quantity);

public class PriceCalculator(IDiscountPolicy discountPolicy)
{
    public const decimal VatRate = 0.08m;

    public decimal Subtotal(IEnumerable<CartItem> items)
    {
        ArgumentNullException.ThrowIfNull(items);
        decimal sum = 0;
        foreach (var item in items)
        {
            if (item.Quantity <= 0)
                throw new ArgumentOutOfRangeException(nameof(items), $"Số lượng của {item.Sku} phải > 0");
            sum += item.UnitPrice * item.Quantity;
        }
        return sum;
    }

    public decimal Total(IEnumerable<CartItem> items, string customerTier)
    {
        var subtotal = Subtotal(items);
        var discounted = subtotal * (1 - discountPolicy.GetDiscountRate(customerTier));
        return Math.Round(discounted * (1 + VatRate), 0, MidpointRounding.AwayFromZero);
    }
}
```

`PriceCalculator` nhận `IDiscountPolicy` qua constructor — nhờ vậy test có thể truyền vào một
"chính sách giảm giá giả" để kiểm soát kết quả.

### Project test

<!-- include: examples/V2Ch06.Calc.Tests/V2Ch06.Calc.Tests.csproj -->
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="xunit.v3" Version="4.0.1" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="../V2Ch06.Calc/V2Ch06.Calc.csproj" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Xunit" />
  </ItemGroup>

</Project>
```

- `xunit.v3` 4.0.1 (checked 2026-09-28) đã gồm *Microsoft.Testing.Platform* (MTP) runner.
- `OutputType` = `Exe`: project test xUnit v3 là một chương trình chạy được.
- File `global.json` của bộ sách có `"test": { "runner": "Microsoft.Testing.Platform" }`.
  Thiếu dòng này, .NET 10 SDK báo lỗi *"Testing with VSTest target is no longer supported by
  Microsoft.Testing.Platform on .NET 10 SDK and later"* (đã gặp thật khi dựng môi trường).

### Test

<!-- include: examples/V2Ch06.Calc.Tests/PriceCalculatorTests.cs -->
```csharp
using V2Ch06.Calc;

namespace V2Ch06.Calc.Tests;

public class PriceCalculatorTests
{
    // Fake (test double): thay thế dependency thật để test độc lập
    private sealed class FixedDiscount(decimal rate) : IDiscountPolicy
    {
        public decimal GetDiscountRate(string customerTier) => rate;
    }

    private static readonly CartItem[] Cart =
    [
        new("KB", 500_000m, 1),
        new("MOUSE", 250_000m, 2),
    ];

    [Fact]
    public void Subtotal_SumsUnitPriceTimesQuantity()
    {
        // Arrange
        var calc = new PriceCalculator(new FixedDiscount(0));

        // Act
        var subtotal = calc.Subtotal(Cart);

        // Assert
        Assert.Equal(1_000_000m, subtotal);
    }

    [Fact]
    public void Subtotal_EmptyCart_IsZero()
    {
        var calc = new PriceCalculator(new FixedDiscount(0));
        Assert.Equal(0m, calc.Subtotal([]));
    }

    [Fact]
    public void Subtotal_ZeroQuantity_Throws()
    {
        var calc = new PriceCalculator(new FixedDiscount(0));
        var ex = Assert.Throws<ArgumentOutOfRangeException>(() => calc.Subtotal([new("X", 10m, 0)]));
        Assert.Contains("X", ex.Message);
    }

    [Theory]
    [InlineData("gold", 972_000)]     // 1,000,000 * 0.90 * 1.08
    [InlineData("silver", 1_026_000)] // 1,000,000 * 0.95 * 1.08
    [InlineData("basic", 1_080_000)]  // 1,000,000 * 1.08
    public void Total_AppliesTierDiscountAndVat(string tier, int expected)
    {
        var calc = new PriceCalculator(new DefaultDiscountPolicy());
        Assert.Equal(expected, calc.Total(Cart, tier));
    }

    [Fact]
    public void Total_UsesInjectedPolicy()
    {
        var calc = new PriceCalculator(new FixedDiscount(0.5m));
        Assert.Equal(540_000m, calc.Total(Cart, "anything"));
    }
}

// Fixture: dữ liệu dùng chung cho nhiều test (tạo 1 lần cho cả class)
public sealed class CatalogFixture
{
    public Dictionary<string, decimal> Prices { get; } = new() { ["KB"] = 500_000m, ["MOUSE"] = 250_000m };
}

public class CatalogTests(CatalogFixture fixture) : IClassFixture<CatalogFixture>
{
    [Fact]
    public void Catalog_HasKeyboard() => Assert.True(fixture.Prices.ContainsKey("KB"));

    [Fact]
    public void Catalog_PricesArePositive() => Assert.All(fixture.Prices.Values, p => Assert.True(p > 0));
}
```

Chạy `dotnet test --output Detailed` (output thật; đã lược các dòng `from <đường dẫn dll>` lặp lại):

<!-- output: examples/V2Ch06.Calc.Tests -->
```text
Running tests from <repo>/books/csharp/vol2-intermediate/examples/V2Ch06.Calc.Tests/bin/Debug/net10.0/V2Ch06.Calc.Tests.dll (net10.0|x64)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Total_AppliesTierDiscountAndVat(tier: "silver", expected: 1026000) (20ms)
passed V2Ch06.Calc.Tests.CatalogTests.Catalog_PricesArePositive (20ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Total_AppliesTierDiscountAndVat(tier: "gold", expected: 972000) (0ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Total_AppliesTierDiscountAndVat(tier: "basic", expected: 1080000) (0ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Total_UsesInjectedPolicy (0ms)
passed V2Ch06.Calc.Tests.CatalogTests.Catalog_HasKeyboard (0ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Subtotal_SumsUnitPriceTimesQuantity (0ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Subtotal_ZeroQuantity_Throws (2ms)
passed V2Ch06.Calc.Tests.PriceCalculatorTests.Subtotal_EmptyCart_IsZero (0ms)
<repo>/books/csharp/vol2-intermediate/examples/V2Ch06.Calc.Tests/bin/Debug/net10.0/V2Ch06.Calc.Tests.dll (net10.0|x64) passed (921ms)

Test run summary: Passed!
  total: 9
  failed: 0
  succeeded: 9
  skipped: 0
  duration: 1s 252ms
```

Chú ý: thứ tự test trong output **không** theo thứ tự trong file. xUnit không đảm bảo thứ tự —
test tốt không phụ thuộc vào nhau.

## Đi sâu

### Arrange – Act – Assert

1. **Arrange**: chuẩn bị object và dữ liệu.
2. **Act**: gọi đúng một hành động cần test.
3. **Assert**: kiểm tra kết quả.

Đặt tên test theo mẫu `Method_Condition_ExpectedResult`, ví dụ
`Subtotal_ZeroQuantity_Throws`. Khi test fail, tên đã nói lên vấn đề.

### Test double

| Loại | Ý nghĩa | Ví dụ |
|---|---|---|
| Fake | cài đặt đơn giản nhưng chạy được | `FixedDiscount(0.5m)` |
| Stub | trả giá trị cố định | |
| Mock | kiểm tra được "đã gọi method nào, mấy lần" | thư viện như NSubstitute, Moq |

Bộ sách dùng fake viết tay để không phụ thuộc thư viện thêm. Với project lớn, thư viện mock
giúp viết nhanh hơn.

### Fixture

- **Constructor + `IDisposable`**: setup/cleanup cho **mỗi** test.
- **`IClassFixture<T>`**: một object `T` dùng chung cho **mọi test trong class** (ví dụ
  `CatalogFixture`). Hợp với tài nguyên đắt: database test, `WebApplicationFactory` (Tập 3).
- **Collection fixture**: dùng chung giữa nhiều class.

### Chạy test chọn lọc

```text
dotnet test --filter-method "*Subtotal*"     # MTP: lọc theo tên method
dotnet test --output Detailed                # in từng test
```

(Các tùy chọn lọc của MTP khác VSTest cũ `--filter`. Xem `dotnet test --help`.)

## Lỗi và bẫy thường gặp

- **Test phụ thuộc thứ tự hoặc trạng thái chung** (static field) → lúc pass lúc fail.
- **Test code dùng `DateTime.Now`, random, mạng** → không ổn định. Inject `IClock`
  (hoặc `TimeProvider` có sẵn từ .NET 8) như Chương 7.
- **Chỉ test "happy path"**: luôn thêm test cho dữ liệu sai, rỗng, biên.
- **Bẫy môi trường (gặp thật khi viết lời giải)**: bộ sách bật `InvariantGlobalization` để
  output ổn định. Ở chế độ này, `string.Normalize(NormalizationForm.FormD)` **không tách dấu
  tiếng Việt**, nên hàm tạo slug trả về `xin-chào-c` thay vì `xin-chao-c` và 6 test fail.
  Tài liệu của dotnet/runtime ghi rõ: ở invariant mode, yêu cầu normalize "trả về chuỗi gốc không đổi". Cách sửa: tắt `InvariantGlobalization` cho project cần xử lý Unicode (cần thư viện ICU
  trên Linux). Test đã phát hiện lỗi này — đúng việc của test!
- **Quên cấu hình `test.runner` trong `global.json`** với .NET 10 SDK + xUnit v3 → lỗi ngay khi chạy.

## Tóm tắt

- xUnit: `[Fact]` cho một trường hợp, `[Theory]` cho nhiều dữ liệu.
- Viết code nhận dependency qua constructor để dễ thay bằng fake khi test.
- .NET 10 + xUnit v3 dùng Microsoft.Testing.Platform, bật trong `global.json`.

## Bài tập (có lời giải)

Viết hàm `Slug.From(title)` chuyển tiêu đề tiếng Việt thành slug URL
(`"Đường đến .NET 10!"` → `"duong-den-net-10"`), và viết test:

1. `[Theory]` với 3 tiêu đề và kết quả mong đợi.
2. Tiêu đề rỗng hoặc toàn khoảng trắng phải ném `ArgumentException`.
3. Dùng `[MemberData]` kiểm tra output chỉ chứa ký tự ASCII với các chữ `Ắ Ằ Ẳ Ẵ Ặ`, `Ơ Ư Đ`.

<details>
<summary>Lời giải</summary>

<!-- include: examples/V2Ch06.Solutions.Tests/V2Ch06.Solutions.Tests.csproj -->
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <IsPackable>false</IsPackable>
    <!-- Normalize(FormD) cần ICU; chế độ InvariantGlobalization không tách dấu tiếng Việt -->
    <InvariantGlobalization>false</InvariantGlobalization>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="xunit.v3" Version="4.0.1" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Xunit" />
  </ItemGroup>

</Project>
```

<!-- include: examples/V2Ch06.Solutions.Tests/SlugTests.cs -->
```csharp
using System.Globalization;
using System.Text;

namespace V2Ch06.Solutions.Tests;

// Code cần test: tạo "slug" cho URL từ tiêu đề tiếng Việt
public static class Slug
{
    public static string From(string title)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(title);
        var normalized = title.Replace('đ', 'd').Replace('Đ', 'D').Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();
        foreach (var c in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(c) == UnicodeCategory.NonSpacingMark) continue; // bỏ dấu
            if (char.IsLetterOrDigit(c)) sb.Append(char.ToLowerInvariant(c));
            else if (sb.Length > 0 && sb[^1] != '-') sb.Append('-');
        }
        return sb.ToString().Trim('-');
    }
}

public class SlugTests
{
    // Bài 1: Theory với nhiều dữ liệu
    [Theory]
    [InlineData("Xin chào C#", "xin-chao-c")]
    [InlineData("Đường đến .NET 10!", "duong-den-net-10")]
    [InlineData("  Nhiều   khoảng   trắng  ", "nhieu-khoang-trang")]
    public void From_CreatesSlug(string title, string expected) => Assert.Equal(expected, Slug.From(title));

    // Bài 2: test exception
    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void From_Blank_Throws(string title) => Assert.Throws<ArgumentException>(() => Slug.From(title));

    // Bài 3: MemberData cho dữ liệu phức tạp hơn
    public static TheoryData<string> Titles => new() { "Ắ Ằ Ẳ Ẵ Ặ", "Ơ Ư Đ", "Lập trình" };

    [Theory]
    [MemberData(nameof(Titles))]
    public void From_OutputIsAscii(string title) => Assert.All(Slug.From(title), c => Assert.True(c < 128));
}
```

<!-- output: examples/V2Ch06.Solutions.Tests -->
```text
Running tests from <repo>/books/csharp/vol2-intermediate/examples/V2Ch06.Solutions.Tests/bin/Debug/net10.0/V2Ch06.Solutions.Tests.dll (net10.0|x64)
passed V2Ch06.Solutions.Tests.SlugTests.From_CreatesSlug(title: "Xin chào C#", expected: "xin-chao-c") (17ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_CreatesSlug(title: "  Nhiều   khoảng   trắng  ", expected: "nhieu-khoang-trang") (0ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_CreatesSlug(title: "Đường đến .NET 10!", expected: "duong-den-net-10") (0ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_Blank_Throws(title: "   ") (1ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_Blank_Throws(title: "") (0ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_OutputIsAscii(title: "Lập trình") (1ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_OutputIsAscii(title: "Ắ Ằ Ẳ Ẵ Ặ") (0ms)
passed V2Ch06.Solutions.Tests.SlugTests.From_OutputIsAscii(title: "Ơ Ư Đ") (0ms)
<repo>/books/csharp/vol2-intermediate/examples/V2Ch06.Solutions.Tests/bin/Debug/net10.0/V2Ch06.Solutions.Tests.dll (net10.0|x64) passed (1s 088ms)

Test run summary: Passed!
  total: 8
  failed: 0
  succeeded: 8
  skipped: 0
  duration: 1s 376ms
```

`đ`/`Đ` không phải "chữ d + dấu" trong Unicode, nên phải thay thủ công trước khi `Normalize`.
</details>

## Nguồn tham khảo (Sources)

- Unit testing C# with xUnit (nguồn Microsoft Learn): https://github.com/dotnet/docs/blob/main/docs/core/testing/unit-testing-csharp-with-xunit.md
- Testing with `dotnet test` (MTP, global.json): https://github.com/dotnet/docs/blob/main/docs/core/testing/unit-testing-with-dotnet-test.md
- xUnit.net repository: https://github.com/xunit/xunit
- xunit.v3 package versions (NuGet API): https://api.nuget.org/v3-flatcontainer/xunit.v3/index.json
- Globalization invariant mode: https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md

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

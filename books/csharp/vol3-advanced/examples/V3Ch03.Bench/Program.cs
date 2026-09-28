using System.Text;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;

// Chạy: dotnet run -c Release -- --job short --filter "*"
BenchmarkSwitcher.FromAssembly(typeof(ParsingBenchmarks).Assembly).Run(args);

[MemoryDiagnoser]            // đo thêm bộ nhớ cấp phát và số lần GC
public class ParsingBenchmarks
{
    private const string Line = "SKU-001,Bàn phím cơ,1200000,15";

    [Benchmark(Baseline = true)]
    public int Split() => int.Parse(Line.Split(',')[3]);

    [Benchmark]
    public int Span()
    {
        ReadOnlySpan<char> s = Line;
        return int.Parse(s[(s.LastIndexOf(',') + 1)..]);
    }
}

[MemoryDiagnoser]
public class ConcatBenchmarks
{
    [Params(10, 1000)]
    public int Count { get; set; }

    [Benchmark(Baseline = true)]
    public string PlusEquals()
    {
        string s = "";
        for (int i = 0; i < Count; i++) s += i;
        return s;
    }

    [Benchmark]
    public string Builder()
    {
        var sb = new StringBuilder();
        for (int i = 0; i < Count; i++) sb.Append(i);
        return sb.ToString();
    }
}

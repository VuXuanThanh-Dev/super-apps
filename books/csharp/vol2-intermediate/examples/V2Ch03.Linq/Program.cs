List<Employee> employees =
[
    new("An", "Backend", 2500, 2019),
    new("Bình", "Frontend", 2200, 2021),
    new("Chi", "Backend", 3100, 2017),
    new("Dũng", "QA", 1800, 2022),
    new("Em", "Frontend", 2600, 2018),
];
List<Department> departments = [new("Backend", "Tầng 3"), new("Frontend", "Tầng 2"), new("QA", "Tầng 1")];

// 1. Where + Select + OrderBy (method syntax)
var seniors = employees
    .Where(e => e.JoinedYear <= 2019)
    .OrderByDescending(e => e.Salary)
    .Select(e => $"{e.Name} ({e.Salary})");
Console.WriteLine("Senior: " + string.Join(", ", seniors));

// 2. Query syntax (giống SQL) - cùng kết quả
var seniors2 = from e in employees
               where e.JoinedYear <= 2019
               orderby e.Salary descending
               select $"{e.Name} ({e.Salary})";
Console.WriteLine("Query syntax giống nhau? " + seniors.SequenceEqual(seniors2));

// 3. Aggregate: Count, Sum, Average, Max, MaxBy
Console.WriteLine($"Số NV={employees.Count}, tổng lương={employees.Sum(e => e.Salary)}, TB={employees.Average(e => e.Salary):F0}");
Console.WriteLine($"Lương cao nhất: {employees.MaxBy(e => e.Salary)!.Name}");
Console.WriteLine($"Có ai lương < 2000? {employees.Any(e => e.Salary < 2000)}; tất cả > 1000? {employees.All(e => e.Salary > 1000)}");

// 4. GroupBy
foreach (var g in employees.GroupBy(e => e.Team).OrderBy(g => g.Key))
    Console.WriteLine($"  {g.Key,-8}: {g.Count()} người, TB {g.Average(e => e.Salary):F0}");

// 5. Join
var withFloor = employees.Join(departments, e => e.Team, d => d.Name, (e, d) => $"{e.Name}@{d.Floor}");
Console.WriteLine("Join: " + string.Join(", ", withFloor));

// 6. First / FirstOrDefault / Single
Console.WriteLine($"First QA: {employees.First(e => e.Team == "QA").Name}");
Console.WriteLine($"FirstOrDefault DevOps: {employees.FirstOrDefault(e => e.Team == "DevOps")?.Name ?? "null"}");

// 7. Phân trang: Skip + Take; Chunk
var page2 = employees.OrderBy(e => e.Name).Skip(2).Take(2).Select(e => e.Name);
Console.WriteLine("Trang 2 (size 2): " + string.Join(", ", page2));
Console.WriteLine("Chunk(2): " + string.Join(" | ", employees.Select(e => e.Name).Chunk(2).Select(c => string.Join(",", c))));

// 8. ToDictionary, Distinct, SelectMany
var byName = employees.ToDictionary(e => e.Name);
Console.WriteLine($"byName[\"Chi\"].Team = {byName["Chi"].Team}");
Console.WriteLine("Teams: " + string.Join(", ", employees.Select(e => e.Team).Distinct()));
string[][] tags = [["c#", "sql"], ["ts", "c#"]];
Console.WriteLine("SelectMany: " + string.Join(", ", tags.SelectMany(t => t).Distinct()));

// 9. Deferred execution: query chỉ chạy khi duyệt
int calls = 0;
var query = employees.Where(e => { calls++; return e.Salary > 2000; });
Console.WriteLine($"Sau khi tạo query: calls={calls}");
var list = query.ToList();
Console.WriteLine($"Sau ToList(): calls={calls}, kết quả={list.Count}");
_ = query.Count();
Console.WriteLine($"Duyệt lần 2: calls={calls} (chạy lại từ đầu!)");

// 10. CountBy / AggregateBy (.NET 9+)
foreach (var (team, count) in employees.CountBy(e => e.Team))
    Console.Write($"{team}={count} ");
Console.WriteLine();

record Employee(string Name, string Team, decimal Salary, int JoinedYear);
record Department(string Name, string Floor);

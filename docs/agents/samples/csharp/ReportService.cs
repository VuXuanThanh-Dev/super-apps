// Called from an ASP.NET Core controller: var report = service.GetReport(42);
public class ReportService
{
    private readonly HttpClient _http;
    public ReportService(HttpClient http) => _http = http;

    public string GetReport(int id)
    {
        var json = _http.GetStringAsync($"https://reports.local/api/{id}").Result;
        return json.Trim();
    }
}

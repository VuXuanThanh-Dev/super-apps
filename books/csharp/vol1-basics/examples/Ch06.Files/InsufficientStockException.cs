namespace Ch06.Files;

// Custom exception: kế thừa Exception, thêm dữ liệu riêng
public class InsufficientStockException(string sku, int requested, int available)
    : Exception($"Không đủ hàng cho {sku}: cần {requested}, còn {available}")
{
    public string Sku { get; } = sku;
    public int Requested { get; } = requested;
    public int Available { get; } = available;
}

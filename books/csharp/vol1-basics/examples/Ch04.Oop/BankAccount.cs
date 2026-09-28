namespace Ch04.Oop;

// Class với field private, property, constructor và phương thức
public class BankAccount
{
    private readonly List<string> _history = [];

    public BankAccount(string owner, decimal initialBalance = 0)
    {
        Owner = owner;
        Balance = initialBalance;
        _history.Add($"Mở tài khoản: {initialBalance:N0}");
    }

    public string Owner { get; }                  // chỉ đọc (read-only)
    public decimal Balance { get; private set; }  // chỉ class này được gán

    // C# 14: từ khóa `field` = backing field do compiler tạo sẵn
    public string Note
    {
        get;
        set => field = string.IsNullOrWhiteSpace(value) ? "(trống)" : value.Trim();
    } = "(trống)";

    public void Deposit(decimal amount)
    {
        if (amount <= 0) throw new ArgumentOutOfRangeException(nameof(amount), "Số tiền phải > 0");
        Balance += amount;
        _history.Add($"Nạp: {amount:N0}");
    }

    public bool TryWithdraw(decimal amount)
    {
        if (amount > Balance) return false;
        Balance -= amount;
        _history.Add($"Rút: {amount:N0}");
        return true;
    }

    public IReadOnlyList<string> History => _history;

    public override string ToString() => $"{Owner}: {Balance:N0} VND";
}

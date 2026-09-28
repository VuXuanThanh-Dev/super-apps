#!/usr/bin/env dotnet
// File-based app (.NET 10): chạy trực tiếp bằng `dotnet run hello.cs`, không cần .csproj.
#:property Nullable=enable

var numbers = new[] { 3, 1, 4, 1, 5, 9, 2, 6 };
Console.WriteLine($"Có {numbers.Length} số, tổng = {numbers.Sum()}, lớn nhất = {numbers.Max()}");

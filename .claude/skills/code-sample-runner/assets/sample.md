# Ví dụ chạy code mẫu

Java:

<!-- run -->
```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Xin chào từ Java " + Runtime.version().feature());
    }
}
```

<!-- output -->
```text
(sẽ bị ghi đè)
```

C#:

<!-- run -->
```csharp
var total = new[] { 1, 2, 3 }.Sum();
Console.WriteLine($"Tổng = {total}");
```

TypeScript:

<!-- run -->
```ts
const greet = (name: string): string => `Hello, ${name}`;
console.log(greet("Nobin"));
```

Lỗi biên dịch có chủ ý:

<!-- run: expect-fail -->
```java
public class Bad {
    public static void main(String[] args) {
        int x = "text";
    }
}
```

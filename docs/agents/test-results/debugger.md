# Test result — debugger

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: debugger
- Correct agent triggered: yes
- Tools the subagent used: Bash, Edit, Read

## Prompt

PriceCalculatorTest fails: 'expected 170.0 but was 200.0'. Run it with javac/java, find the root cause and fix it.

## Result (verbatim)

### Triệu chứng
`PriceCalculatorTest` fails with `java.lang.AssertionError: expected 170.0 but was 200.0` when calling `PriceCalculator.discounted(200, 15)`.

### Tái hiện (lệnh / test) → kết quả trước khi sửa
```
javac PriceCalculator.java PriceCalculatorTest.java -d out
java -cp out PriceCalculatorTest
```
Output before fix:
```
Exception in thread "main" java.lang.AssertionError: expected 170.0 but was 200.0
	at PriceCalculatorTest.main(PriceCalculatorTest.java:5)
```

### Giả thuyết và cách kiểm tra
1. Integer division truncating the percent fraction to 0 — confirmed by reading `PriceCalculator.java:4`: `percent / 100` with both operands `int` evaluates `15/100` to `0` in Java, making the whole discount term vanish. Verified by reproducing the exact test failure above (200.0 unchanged = discount of 0 applied).
2. Wrong discount formula (e.g., subtracting percent instead of price*percent) — rejected: the formula structure `price - price * discountFraction` is correct; only the fraction computation was wrong.
3. Test itself is wrong — rejected: `discounted(200, 15)` doc comment (`PriceCalculator.java:2`) states expected result is exactly `170.0`, matching the test, so the test is correct and the implementation is the bug.

### Nguyên nhân gốc (root cause)
`PriceCalculator.java:4` computes `percent / 100` using integer division (both `percent` and `100` are `int`), so for `percent = 15` this evaluates to `0` instead of `0.15`. The discount amount `price * 0` is always `0`, so `discounted()` always returns the original price unchanged.

### Bản sửa (file — thay đổi)
File: `PriceCalculator.java`

```diff
     public static double discounted(int price, int percent) {
-        return price - price * (percent / 100);
+        return price - price * (percent / 100.0);
     }
```

Forcing floating-point division (`100.0`) makes `percent / 100.0` evaluate to `0.15`, so `200 - 200 * 0.15 = 170.0` as expected.

### Bằng chứng sau khi sửa (lệnh → kết quả thật)
```
javac PriceCalculator.java PriceCalculatorTest.java -d out
java -cp out PriceCalculatorTest
```
Output: `PASS`

### Phòng tránh lần sau
Add a few more assertions to the test (e.g., `discounted(50, 10)` → `45.0`, `discounted(100, 0)` → `100.0`) to catch integer-division regressions across a range of inputs, and prefer explicit floating-point literals (`100.0`) whenever a ratio or percentage is computed from `int` operands.

`PriceCalculatorTest.java` was not modified — it was correct.

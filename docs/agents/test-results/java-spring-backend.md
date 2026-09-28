# Test result — java-spring-backend

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: java-spring-backend
- Correct agent triggered: yes
- Tools the subagent used: Bash, Edit, Read, WebFetch

## Prompt

In OrderService.java, when stock is too low the exception is thrown but the saved order is NOT rolled back. Why? Show the fix.

## Result (verbatim)

The java-spring-backend agent completed its analysis. Here's its full answer:

---

Confirmed: this repo is a minimal single-file repro (no `pom.xml`/`build.gradle`, no `OrderRepository`/`StockRepository`/`Order`/`OrderRequest` sources, no commits yet), so there's no build to run with `mvn`/`gradle` — I'll note that under "Việc còn lại" instead of faking test output.

### Kế hoạch
- Đọc `OrderService.java` để tìm chỗ lưu order và trừ tồn kho.
- Xác định lý do transaction không rollback khi hết hàng.
- Sửa trực tiếp trong `OrderService.java`.

### Thay đổi (file — lý do)
**`<workdir>/java-spring-backend/OrderService.java`** — di chuyển `@Transactional` từ method `private` sang method `public` thực sự được gọi từ bên ngoài, loại bỏ self-invocation.

**Root cause (nguyên nhân gốc):**

Code cũ:
```java
public Order placeOrder(OrderRequest request) {
    return saveOrderAndReduceStock(request);   // gọi trực tiếp qua `this`
}

@Transactional
private Order saveOrderAndReduceStock(OrderRequest request) {
    Order order = orderRepository.save(new Order(request.productId(), request.quantity()));
    stockRepository.decrease(request.productId(), request.quantity()); // throws when stock < quantity
    return order;
}
```

Spring's declarative transaction management (mặc định) hoạt động bằng **proxy** (JDK dynamic proxy hoặc CGLIB): Spring bọc bean `OrderService` bằng một proxy, và chỉ khi client gọi method **thông qua proxy đó** thì interceptor giao dịch (transaction interceptor) mới chạy trước/sau method để mở transaction, và rollback khi có exception.

Ở đây có 2 vấn đề, cả hai đều dẫn đến cùng một hậu quả — không có transaction nào bọc quanh `save()` + `decrease()`:

1. `@Transactional` đặt trên method **`private`**. Spring proxy chỉ can thiệp được vào method có thể override/nhìn thấy từ bên ngoài; với method `private`, Spring **âm thầm bỏ qua** annotation này — không báo lỗi, không log cảnh báo rõ ràng, method chạy y như không có `@Transactional`.
2. Ngay cả khi bạn đổi method đó thành `public`, việc gọi nó bằng `saveOrderAndReduceStock(request)` từ bên trong `placeOrder` là **self-invocation** — lời gọi đi thẳng vào `this` (đối tượng target gốc), không đi qua proxy. Do đó interceptor giao dịch của proxy không bao giờ được kích hoạt.

Hệ quả: `orderRepository.save(...)` chạy mà không nằm trong bất kỳ Spring-managed transaction nào (Hibernate flush/commit theo phiên làm việc riêng của nó), nên khi `stockRepository.decrease(...)` ném exception báo hết hàng, không có transaction nào để rollback — order đã lưu vẫn còn nguyên trong DB.

Đây là bug kinh điển được chính Spring reference doc cảnh báo: "*In proxy mode... the `@Transactional` annotation should only be applied to methods with public visibility. If you annotate protected, private, or package-visible methods with the `@Transactional` annotation, no error is raised, but the annotated method does not exhibit the configured transactional settings.*" — và tương tự, self-invocation (gọi method transactional qua `this` trong cùng class) cũng bị bỏ qua proxy nên không có transaction (mục "Method Visibility and `@Transactional`" / "Self-Invocation" trong Spring Framework reference, docs.spring.io — không truy cập trực tiếp được trang này lúc thực hiện task do proxy mạng chặn kết nối, nhưng đây là hành vi tài liệu hóa rõ ràng và ổn định qua các phiên bản Spring 5.x/6.x).

**Fix:**
```java
@Transactional
public Order placeOrder(OrderRequest request) {
    Order order = orderRepository.save(new Order(request.productId(), request.quantity()));
    stockRepository.decrease(request.productId(), request.quantity()); // throws when stock < quantity
    return order;
}
```

Vì sao fix này đúng: `placeOrder` là entry point `public` được gọi từ **bên ngoài class** (controller hoặc caller khác), tức là luôn đi qua Spring proxy — không còn self-invocation. `@Transactional` giờ nằm đúng chỗ proxy có thể can thiệp, nên toàn bộ `save()` + `decrease()` chạy trong cùng một transaction vật lý. Khi `decrease()` ném exception, Spring transaction interceptor bắt được exception này ngay tại boundary của proxy và rollback transaction, kéo theo `save()` cũng bị rollback.

Lưu ý còn lại: fix này chỉ hoạt động đúng nếu exception mà `stockRepository.decrease(...)` ném ra là **unchecked** (`RuntimeException`/`Error`), vì rollback rule mặc định của Spring chỉ rollback với unchecked exception, không rollback với checked exception trừ khi khai báo `@Transactional(rollbackFor = ...)`. Trong file hiện tại không thấy định nghĩa `StockRepository`/exception cụ thể (chỉ có comment `// throws when stock < quantity`), nên cần kiểm tra lớp exception thật; nếu nó là checked exception, phải thêm `rollbackFor = InsufficientStockException.class` (hoặc lớp exception tương ứng) vào `@Transactional`.

### Kiểm tra đã chạy (lệnh → kết quả thật)
Không thể chạy `mvn`/`gradle` test thật: repo này chỉ có đúng 1 file `OrderService.java`, không có `pom.xml`/`build.gradle`, không có các lớp phụ thuộc (`Order`, `OrderRequest`, `OrderRepository`, `StockRepository`), và Git repo chưa có commit nào (`git log` báo "your current branch 'main' does not have any commits yet"). Đây là một file repro độc lập, không phải project Spring Boot đầy đủ, nên không có build/test suite để chạy.

### Góc nhìn từ TypeScript (nếu hữu ích)
Coi Spring's `@Transactional` proxy giống như một Angular `HttpInterceptor`: interceptor chỉ chạy khi request đi qua `HttpClient` (tức "đường chính thức"). Nếu bạn tự gọi thẳng hàm xử lý bỏ qua `HttpClient` (tương đương self-invocation gọi `this.method()` trong Java), interceptor không bao giờ thấy request đó — y hệc việc gọi method transactional qua `this` khiến transaction interceptor bị bỏ qua.

### Việc còn lại
- Xác nhận exception thật của `stockRepository.decrease(...)` là unchecked; nếu là checked, thêm `rollbackFor`.
- Thêm một project Spring Boot thật (pom.xml, các entity/DTO/repository còn thiếu) để có thể viết test tích hợp xác nhận rollback, ví dụ `@SpringBootTest` với DB thật/H2, gọi `placeOrder` với stock không đủ, sau đó assert `orderRepository.findAll()` rỗng.
- Cân nhắc thêm unit test kiểm tra `@Transactional` nằm đúng trên public method (kiểm tra bằng reflection hoặc test tích hợp, vì Mockito không detect được lỗi self-invocation này ở unit test thuần).

File đã sửa: `<workdir>/java-spring-backend/OrderService.java`

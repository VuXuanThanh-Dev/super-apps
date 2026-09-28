# COVERAGE — Mục tiêu thi 1Z0-830 → chương → ví dụ → câu hỏi

> File này được **sinh tự động** bởi `python3 tools/book.py coverage` từ:
> `tools/objectives.yaml` (danh sách mục tiêu), dòng `// objective: x.y` trong từng ví dụ,
> và trường `topic` của từng câu hỏi trong `examples/questions/*/questions.yaml`.
>
> Danh sách mục tiêu lấy từ bảng mục tiêu trong repo eh3rrera/ocpj21-book (ghi là mục tiêu chính thức của Oracle);
> **UNVERIFIED** so với trang Oracle (bị chặn trong sandbox, kiểm tra 2026-09-28). Số thứ tự x.y là của sách này.

**Độ phủ: 4/26 mục tiêu có đủ chương + ví dụ + câu hỏi chương.**

| ID | Mục tiêu (Oracle, tiếng Anh) | Chương | Ví dụ | Câu hỏi chương | Câu hỏi thi thử |
|---|---|---|---|---|---|
| 1.1 | Use primitives and wrapper classes. | [ch01](chapters/ch01-du-lieu.md) | `ch01/Ex01_Primitives`, `ch01/Ex02_Wrappers`, `ch01/Ex13_NarrowingError` | 01-01, 01-10, 01-13, 01-19, 01-20 | — |
| 1.2 | Evaluate arithmetic and boolean expressions, using the Math API and by applying precedence rules, type conversions, and casting. | [ch01](chapters/ch01-du-lieu.md) | `ch01/Ex03_Promotion`, `ch01/Ex04_Casting`, `ch01/Ex05_Operators`, `ch01/Ex06_MathApi`, `ch01/Ex13_NarrowingError` | 01-02, 01-03, 01-11, 01-12, 01-17 | — |
| 1.3 | Manipulate text, including text blocks, using String and StringBuilder classes. | [ch01](chapters/ch01-du-lieu.md) | `ch01/Ex07_Strings`, `ch01/Ex08_StringBuilder`, `ch01/Ex09_TextBlocks` | 01-04, 01-05, 01-06, 01-14, 01-15 | — |
| 1.4 | Manipulate date, time, duration, period, instant and time-zone objects including daylight saving time using Date-Time API. | [ch01](chapters/ch01-du-lieu.md) | `ch01/Ex10_LocalDate`, `ch01/Ex11_PeriodDuration`, `ch01/Ex12_ZonesDst` | 01-07, 01-08, 01-09, 01-16, 01-18 | — |
| 2.1 | Create program flow control constructs including if/else, switch statements and expressions, loops, and break and continue statements. | ch02 | — | — | — |
| 3.1 | Declare and instantiate Java objects including nested class objects, and explain the object life-cycle including creation, reassigning references, and garbage collection. | ch03 | — | — | — |
| 3.2 | Create classes and records, and define and use instance and static fields and methods, constructors, and instance and static initializers. | ch03 | — | — | — |
| 3.3 | Implement overloading, including var-arg methods. | ch03 | — | — | — |
| 3.4 | Understand variable scopes, apply encapsulation, and create immutable objects. Use local variable type inference. | ch03 | — | — | — |
| 3.5 | Implement inheritance, including abstract and sealed types as well as record classes. Override methods, including that of the Object class. Implement polymorphism and differentiate between object type and reference type. Perform reference type casting, identify object types using the instanceof operator, and pattern matching with the instanceof operator and the switch construct. | ch03 | — | — | — |
| 3.6 | Create and use interfaces, identify functional interfaces, and utilize private, static, and default interface methods. | ch03 | — | — | — |
| 3.7 | Create and use enum types with fields, methods, and constructors. | ch03 | — | — | — |
| 4.1 | Handle exceptions using try/catch/finally, try-with-resources, and multi-catch blocks, including custom exceptions. | ch04 | — | — | — |
| 5.1 | Create arrays, List, Set, Map and Deque collections, and add, remove, update, retrieve and sort their elements. | ch05 | — | — | — |
| 6.1 | Use Java object and primitive Streams, including lambda expressions implementing functional interfaces, to create, filter, transform, process, and sort data. | ch06 | — | — | — |
| 6.2 | Perform decomposition, concatenation, and reduction, and grouping and partitioning on sequential and parallel streams. | ch06 | — | — | — |
| 7.1 | Define modules and expose module content, including that by reflection, and declare module dependencies, define services, providers, and consumers. | ch07 | — | — | — |
| 7.2 | Compile Java code, create modular and non-modular jars, runtime images, and implement migration to modules using unnamed and automatic modules. | ch07 | — | — | — |
| 8.1 | Create both platform and virtual threads. Use both Runnable and Callable objects, manage the thread lifecycle, and use different Executor services and concurrent API to run tasks. | ch08 | — | — | — |
| 8.2 | Develop thread-safe code, using locking mechanisms and concurrent API. | ch08 | — | — | — |
| 8.3 | Process Java collections concurrently and utilize parallel streams. | ch08 | — | — | — |
| 9.1 | Read and write console and file data using I/O streams. | ch09 | — | — | — |
| 9.2 | Serialize and de-serialize Java objects. | ch09 | — | — | — |
| 9.3 | Construct, traverse, create, read, and write Path objects and their properties using the java.nio.file API. | ch09 | — | — | — |
| 10.1 | Implement localization using locales and resource bundles. | ch10 | — | — | — |
| 10.2 | Parse and format messages, dates, times, and numbers, including currency and percentage values. | ch10 | — | — | — |

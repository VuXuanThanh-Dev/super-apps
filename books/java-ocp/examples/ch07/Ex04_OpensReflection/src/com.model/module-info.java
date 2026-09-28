module com.model {
    exports com.model;                  // compile-time + public members lúc chạy
    // "opens com.model;" sẽ cho phép reflection vào cả thành viên private
}

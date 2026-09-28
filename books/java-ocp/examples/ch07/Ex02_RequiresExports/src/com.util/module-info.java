module com.util {
    exports com.util.api;          // chỉ package này được module khác dùng
    // com.util.internal KHÔNG export → bị "đóng gói mạnh" (strong encapsulation)
}

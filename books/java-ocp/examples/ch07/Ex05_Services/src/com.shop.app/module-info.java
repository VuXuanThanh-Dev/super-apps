module com.shop.app {
    requires com.shop.api;
    uses com.shop.api.PaymentService;   // consumer khai báo sẽ tìm service này
}

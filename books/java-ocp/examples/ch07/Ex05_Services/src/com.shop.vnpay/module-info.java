module com.shop.vnpay {
    requires com.shop.api;
    provides com.shop.api.PaymentService with com.shop.vnpay.VnPay;   // service provider
    // KHÔNG cần exports com.shop.vnpay: consumer không biết lớp cài đặt
}

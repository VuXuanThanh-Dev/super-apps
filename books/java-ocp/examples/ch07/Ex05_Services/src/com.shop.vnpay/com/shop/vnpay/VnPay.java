package com.shop.vnpay;

import com.shop.api.PaymentService;

public class VnPay implements PaymentService {
    public VnPay() { }                  // provider cần constructor public không tham số (hoặc method static provider())
    public String name() { return "VNPay"; }
    public String pay(long amount) { return "paid " + amount + " VND via " + name(); }
}

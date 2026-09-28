package com.shop.app;

import com.shop.api.PaymentService;
import java.util.ServiceLoader;

public class Checkout {
    public static void main(String[] args) {
        ServiceLoader<PaymentService> loader = ServiceLoader.load(PaymentService.class);
        long count = loader.stream().count();
        System.out.println("providers found: " + count);
        loader.findFirst().ifPresentOrElse(
                p -> System.out.println(p.pay(150_000)),
                () -> System.out.println("no payment provider"));
    }
}

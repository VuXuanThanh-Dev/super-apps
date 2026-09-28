package com.top;

import com.base.Money;
import com.mid.Wallet;

public class Main {
    public static void main(String[] args) {
        Money m = Wallet.balance();
        System.out.println("balance = " + m.amount());
        System.out.println("com.top reads com.base? " + Main.class.getModule()
                .canRead(Money.class.getModule()));
    }
}

package com.app;

import com.util.internal.Helper;     // package không được export

public class App {
    public static void main(String[] args) {
        System.out.println(Helper.clean(" x "));
    }
}

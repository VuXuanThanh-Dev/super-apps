package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        ServiceLoader.load(com.api.Tax.class).findFirst()
                .ifPresent(t -> System.out.println("rate=" + t.rate()));
    }
}

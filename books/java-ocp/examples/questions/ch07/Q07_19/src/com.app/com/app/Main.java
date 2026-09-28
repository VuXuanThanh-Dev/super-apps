package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        var first = ServiceLoader.load(com.api.Greeter.class).findFirst();
        System.out.println(first.isPresent() ? first.get().greet() : "no provider");
    }
}

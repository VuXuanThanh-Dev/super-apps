package com.app;
import java.util.ServiceLoader;
public class Main {
    public static void main(String[] args) {
        System.out.println("count=" + ServiceLoader.load(com.api.Greeter.class).stream().count());
    }
}

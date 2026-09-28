package com.app;
public class Main {
    public static void main(String[] args) {
        long n = java.util.ServiceLoader.load(com.api.Svc.class).stream().count();
        System.out.println(n > 0 ? "found" : "none");
    }
}

package com.hello;

public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from a custom runtime image! modules in boot layer: "
                + ModuleLayer.boot().modules().size());
    }
}
